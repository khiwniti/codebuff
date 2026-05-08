from __future__ import annotations

import json
import time
from typing import Any


from ...db.database import async_session_factory
from ...db.models import Session
from .base import StorageEngine


class SQLiteStorageEngine(StorageEngine):
    """SQLite-backed storage for session state and local rate limiting."""

    def __init__(self):
        # In-memory fallback for idempotency when using SQLite backend
        self._idempotency: dict[str, tuple[dict[str, Any], float]] = {}

    async def get_session_state(self, session_id: str) -> dict[str, Any] | None:
        async with async_session_factory() as db_session:
            # We assume session_id passed here is the string key or ID
            # In current models, Session.id is an integer.
            # If session_id is a string (e.g. "default"), we might need a lookup by key.
            # For simplicity, let's try to parse as int first.
            try:
                sid = int(session_id)
            except ValueError:
                # If it's a string, we need to handle it.
                # For now, let's assume we use the primary key.
                return None

            session = await db_session.get(Session, sid)
            if not session:
                return None

            return {
                "tool_id_map": json.loads(session.tool_id_map_json or "{}"),
                "transformer_settings": json.loads(session.transformer_settings_json or "[]"),
                "tokens_used": session.tokens_used,
            }

    async def save_session_state(
        self,
        session_id: str,
        tool_id_map: dict[str, Any],
        transformer_settings: list[dict[str, Any]],
        tokens_inc: int = 0,
    ) -> None:
        async with async_session_factory() as db_session:
            try:
                sid = int(session_id)
            except ValueError:
                return

            session = await db_session.get(Session, sid)
            if session:
                session.tool_id_map_json = json.dumps(tool_id_map)
                session.transformer_settings_json = json.dumps(transformer_settings)
                session.tokens_used += tokens_inc
                await db_session.commit()

    async def get_rate_limit(self, key: str) -> int:
        # SQLite doesn't currently store transient rate-limit counters in a
        # separate table. We return 0 and let the in-memory limiter (if any) handle it,
        # or implement a simple table if distributed SQLite is desired.
        return 0

    async def increment_rate_limit(self, key: str, window_seconds: int = 60) -> int:
        # Not implemented for SQLite to avoid blocking.
        # SQLite storage is intended for local dev where in-memory is fine.
        return 1

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
