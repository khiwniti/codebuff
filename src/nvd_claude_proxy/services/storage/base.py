from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any


class StorageEngine(ABC):
    """Abstract base class for persistent state storage."""

    @abstractmethod
    async def get_session_state(self, session_id: str) -> dict[str, Any] | None:
        """Retrieve tool_id_map and transformer_settings for a session."""
        pass

    @abstractmethod
    async def save_session_state(
        self,
        session_id: str,
        tool_id_map: dict[str, Any],
        transformer_settings: list[dict[str, Any]],
        tokens_inc: int = 0,
    ) -> None:
        """Persist session state and increment token usage."""
        pass

    @abstractmethod
    async def get_rate_limit(self, key: str) -> int:
        """Get the current request count for a rate-limit key."""
        pass

    @abstractmethod
    async def increment_rate_limit(self, key: str, window_seconds: int = 60) -> int:
        """Increment request count and return new value."""
        pass

    @abstractmethod
    async def get_idempotency(self, key: str) -> dict[str, Any] | None:
        """Retrieve a cached response for an idempotency key."""
        pass

    @abstractmethod
    async def save_idempotency(self, key: str, response: dict[str, Any], ttl: int = 86400) -> None:
        """Cache a response for an idempotency key with a TTL (default 24h)."""
        pass
