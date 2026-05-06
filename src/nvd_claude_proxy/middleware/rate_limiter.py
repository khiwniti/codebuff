from __future__ import annotations

import time
from collections import defaultdict, deque

import structlog
from fastapi import Request
from fastapi.responses import ORJSONResponse
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.responses import Response

_log = structlog.get_logger("nvd_claude_proxy.rate_limiter")


class RateLimiterMiddleware(BaseHTTPMiddleware):
    """In-process per-client rate limiter kept for tests and simple local apps.

    Production apps use DistributedRateLimiterMiddleware below so multiple
    workers/instances can share counters through the configured StorageEngine.
    This compatibility middleware preserves the old constructor API
    `rpm_limit=...` used by unit tests and lightweight embeddings.
    """

    def __init__(self, app, rpm_limit: int = 0) -> None:
        super().__init__(app)
        self.rpm_limit = rpm_limit
        self._requests: dict[str, deque[float]] = defaultdict(deque)

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        if self.rpm_limit <= 0 or request.url.path != "/v1/messages":
            return await call_next(request)

        key = await self._client_key(request)
        now = time.monotonic()
        window_start = now - 60.0
        bucket = self._requests[key]
        while bucket and bucket[0] <= window_start:
            bucket.popleft()

        if len(bucket) >= self.rpm_limit:
            retry_after = max(1, int(60.0 - (now - bucket[0]))) if bucket else 1
            return ORJSONResponse(
                {
                    "type": "error",
                    "error": {
                        "type": "rate_limit_error",
                        "message": f"Rate limit exceeded: {self.rpm_limit} RPM",
                    },
                },
                status_code=429,
                headers={"retry-after": str(retry_after)},
            )

        bucket.append(now)
        return await call_next(request)

    async def _client_key(self, request: Request) -> str:
        metadata_user = None
        try:
            body = await request.json()
            metadata = body.get("metadata") if isinstance(body, dict) else None
            metadata_user = metadata.get("user_id") if isinstance(metadata, dict) else None
        except Exception:
            metadata_user = None

        return (
            request.headers.get("anthropic-metadata-user-id")
            or metadata_user
            or (request.client.host if request.client else "unknown")
        )


class DistributedRateLimiterMiddleware(BaseHTTPMiddleware):
    """Global rate limiter using the configured StorageEngine."""

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        settings = request.app.state.settings
        limit = settings.rate_limit_rpm

        if limit <= 0:
            return await call_next(request)

        # Key on user_id if present, else client IP
        user_id = request.headers.get("anthropic-metadata-user-id")
        if not user_id:
            user_id = request.client.host if request.client else "unknown"

        key = f"rate_limit:{user_id}"
        storage = request.app.state.storage

        try:
            count = await storage.increment_rate_limit(key, window_seconds=60)

            if count > limit:
                _log.warning("rate_limit.exceeded", user_id=user_id, count=count, limit=limit)
                return ORJSONResponse(
                    {
                        "type": "error",
                        "error": {
                            "type": "rate_limit_error",
                            "message": f"Rate limit exceeded: {limit} RPM. Current: {count} RPM",
                        },
                    },
                    status_code=429,
                )
        except Exception as e:
            # Don't block requests if storage fails, but log it
            _log.error("rate_limit.storage_error", error=str(e))

        return await call_next(request)
