from __future__ import annotations

import json
from typing import Any

try:
    import redis.asyncio as redis

    _HAS_REDIS = True
except ImportError:
    _HAS_REDIS = False

from .base import StorageEngine


class RedisStorageEngine(StorageEngine):
    """Redis-backed storage for distributed session state and rate limiting."""

    def __init__(self, url: str, password: str | None = None, prefix: str = "ncp:") -> None:
        if not _HAS_REDIS:
            raise ImportError("redis[hiredis] is required for RedisStorageEngine")
        self.client = redis.from_url(url, password=password, decode_responses=True)
        self.prefix = prefix

    def _s_key(self, session_id: str) -> str:
        return f"{self.prefix}session:{session_id}"

    def _rl_key(self, key: str) -> str:
        return f"{self.prefix}rate_limit:{key}"

    def _idem_key(self, key: str) -> str:
        return f"{self.prefix}idempotency:{key}"

    async def get_session_state(self, session_id: str) -> dict[str, Any] | None:
        data = await self.client.get(self._s_key(session_id))
        if not data:
            return None
        return json.loads(data)

    async def save_session_state(
        self,
        session_id: str,
        tool_id_map: dict[str, Any],
        transformer_settings: list[dict[str, Any]],
        tokens_inc: int = 0,
    ) -> None:
        key = self._s_key(session_id)
        # Load existing for token accumulation
        existing = await self.get_session_state(session_id) or {}
        tokens_used = existing.get("tokens_used", 0) + tokens_inc

        state = {
            "tool_id_map": tool_id_map,
            "transformer_settings": transformer_settings,
            "tokens_used": tokens_used,
        }
        # TTL of 24 hours for sessions in Redis to prevent leak
        await self.client.set(key, json.dumps(state), ex=86400)

    async def get_rate_limit(self, key: str) -> int:
        val = await self.client.get(self._rl_key(key))
        return int(val) if val else 0

    async def increment_rate_limit(self, key: str, window_seconds: int = 60) -> int:
        k = self._rl_key(key)
        async with self.client.pipeline(transaction=True) as pipe:
            await pipe.incr(k)
            await pipe.expire(k, window_seconds, nx=True)
            res = await pipe.execute()
        return res[0]

    async def get_idempotency(self, key: str) -> dict[str, Any] | None:
        data = await self.client.get(self._idem_key(key))
        if not data:
            return None
        try:
            return json.loads(data)
        except Exception:
            return None

    async def save_idempotency(self, key: str, response: dict[str, Any], ttl: int = 86400) -> None:
        try:
            await self.client.set(self._idem_key(key), json.dumps(response), ex=ttl)
        except Exception:
            pass
