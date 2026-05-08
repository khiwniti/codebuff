from __future__ import annotations

from typing import TYPE_CHECKING, Any, Callable

from fastapi import Request
import structlog

from ..db.models import Session
from ..translators.tool_translator import ToolIdMap
from ..translators.transformers import TransformerChain

if TYPE_CHECKING:
    from ..config.models import CapabilityManifest

_log = structlog.get_logger("nvd_claude_proxy.session_service")


class SessionService:
    @staticmethod
    async def get_isolated_tool_id_map(request: Request, session_obj: Session | None) -> ToolIdMap:
        """Load ToolIdMap from session, or create fresh if missing."""
        if not session_obj:
            return ToolIdMap()

        storage = request.app.state.storage
        state = await storage.get_session_state(str(session_obj.id))
        if not state or not state.get("tool_id_map"):
            return ToolIdMap()

        try:
            return ToolIdMap.from_dict(state["tool_id_map"])
        except Exception:
            _log.exception("session.tool_id_map_load_failed", session_id=session_obj.id)
            return ToolIdMap()

    @staticmethod
    async def get_isolated_transformer_chain(
        request: Request,
        session_obj: Session | None,
        spec: CapabilityManifest,
        build_default_fn: Callable[
            [CapabilityManifest, Callable[[str, Any], None] | None], TransformerChain
        ],
        on_fix: Callable[[str, Any], None] | None = None,
    ) -> TransformerChain:
        """Load TransformerChain from session, or use default factory if missing."""
        if not session_obj:
            return build_default_fn(spec, on_fix)

        storage = request.app.state.storage
        state = await storage.get_session_state(str(session_obj.id))
        if not state or not state.get("transformer_settings"):
            return build_default_fn(spec, on_fix)

        try:
            return TransformerChain.from_dict(state["transformer_settings"], on_fix=on_fix)
        except Exception:
            _log.exception(
                "session.transformer_chain_load_failed",
                session_id=session_obj.id,
            )
            return build_default_fn(spec, on_fix)

    @staticmethod
    async def save_session_state(
        request: Request,
        session_id: int,
        tool_id_map: ToolIdMap,
        transformer_chain: TransformerChain,
        tokens_inc: int = 0,
    ) -> None:
        """Persist serialized state via the configured storage engine."""
        storage = request.app.state.storage
        await storage.save_session_state(
            session_id=str(session_id),
            tool_id_map=tool_id_map.to_dict(),
            transformer_settings=transformer_chain.to_dict(),
            tokens_inc=tokens_inc,
        )
        _log.debug("session.state_saved", session_id=session_id, tokens_inc=tokens_inc)
