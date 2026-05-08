from __future__ import annotations

from typing import TYPE_CHECKING
import structlog

if TYPE_CHECKING:
    from ...config.settings import Settings
    from .base import StorageEngine

_log = structlog.get_logger("nvd_claude_proxy.storage")


def create_storage_engine(settings: Settings) -> StorageEngine:
    """Factory to create the configured storage engine with reliable fallbacks."""

    if settings.storage_engine == "redis":
        if settings.redis_url:
            try:
                from .redis import RedisStorageEngine

                engine = RedisStorageEngine(
                    url=settings.redis_url,
                    password=settings.redis_password,
                    prefix=settings.redis_prefix,
                )
                _log.info("storage.provider_selected", type="redis", url=settings.redis_url)
                return engine
            except (ImportError, Exception) as e:
                _log.error("storage.redis_init_failed", error=str(e))
        else:
            _log.warning("storage.redis_url_missing", action="falling_back_to_sqlite")

    if settings.storage_engine == "sqlite":
        try:
            from .sqlite import SQLiteStorageEngine

            _log.info("storage.provider_selected", type="sqlite")
            return SQLiteStorageEngine()
        except Exception as e:
            _log.error("storage.sqlite_init_failed", error=str(e))

    # Ultimate fallback: In-memory (stateless across restarts)
    from .memory import InMemoryStorageEngine

    _log.warning("storage.provider_selected", type="memory", reason="all_others_failed")
    return InMemoryStorageEngine()
