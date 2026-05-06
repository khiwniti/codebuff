from __future__ import annotations

import time
from typing import Any

from .base import StorageEngine


class InMemoryStorageEngine(StorageEngine):
    """Fallback in-memory storage for non-persistent environments."""

    def __init__(self):
        self._sessions: dict[str, dict[str, Any]] = {}
        self._rate_limits: dict[str, list[float]] = {}
        # Stores (response, expires_at)
        self._idempotency: dict[str, tuple[dict[str, Any], float]] = {}

    async def get_session_state(self, session_id: str) -> dict[str, Any] | None:
        return self._sessions.get(session_id)

    async def save_session_state(
        self,
        session_id: str,
        tool_id_map: dict[str, Any],
        transformer_settings: list[dict[str, Any]],
        tokens_inc: int = 0,
    ) -> None:
        state = self._sessions.setdefault(
            session_id, {"tool_id_map": {}, "transformer_settings": [], "tokens_used": 0}
        )
        state["tool_id_map"] = tool_id_map
        state["transformer_settings"] = transformer_settings
        state["tokens_used"] += tokens_inc

    async def get_rate_limit(self, key: str) -> int:
        now = time.time()
        # Clean expired
        self._rate_limits[key] = [t for t in self._rate_limits.get(key, []) if t > now - 60]
        return len(self._rate_limits[key])

    async def increment_rate_limit(self, key: str, window_seconds: int = 60) -> int:
        now = time.time()
        hits = self._rate_limits.setdefault(key, [])
        hits.append(now)
        # Clean expired
        self._rate_limits[key] = [t for t in hits if t > now - window_seconds]
        return len(self._rate_limits[key])

    async def get_idempotency(self, key: str) -> dict[str, Any] | None:
        now = time.time()
        entry = self._idempotency.get(key)
        if entry:
            resp, expires_at = entry
            if expires_at > now:
                return resp
            else:
                del self._idempotency[key]
        return None

    async def save_idempotency(self, key: str, response: dict[str, Any], ttl: int = 86400) -> None:
        self._idempotency[key] = (response, time.time() + ttl)
