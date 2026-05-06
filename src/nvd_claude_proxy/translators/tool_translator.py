"""Tool schema + tool_choice + id-map helpers."""

from __future__ import annotations

import re
from typing import Any

import structlog

from ..util.ids import new_tool_use_id
from .schema_sanitizer import (
    sanitize_input_schema,
    sanitize_tool_name,
    truncate_description,
)

_log = structlog.get_logger("nvd_claude_proxy.tools")

# Anthropic server-tool `type` strings end in a date. The full catalogue (as of
# early 2026) — kept explicit rather than just matching `_YYYYMMDD` so we can
# log which specific tool was dropped.
_SERVER_TOOL_TYPES = {
    "web_search_20250305",
    "web_search_20250728",
    "bash_20250124",
    "bash_20250728",
    "computer_20250124",
    "computer_20250728",
    "code_execution_20250522",
    "code_execution_20260120",
    "text_editor_20250124",
    "text_editor_20250728",
    "memory_20250818",
}
# Regex catch-all in case Anthropic releases new dated server tools.
_DATED_TOOL_RE = re.compile(r".+_(20\d{6})$")

# MCP client tools (anthropic-beta: mcp-client-*) arrive with `type: "custom"`
# or no type, plus a normal `input_schema`. They behave like regular function
# tools from the model's POV, so we forward them after sanitization.
_PASSTHROUGH_TOOL_TYPES = {None, "custom", "function"}

# Per-tool description cap when a request carries many tools. Keeps the
# per-tool prompt footprint modest without losing intent. Tools are truncated
# only when the aggregate tool-schema budget is exceeded (see
# `anthropic_tools_to_openai`).
_DEFAULT_DESC_CAP = 480
_TIGHT_DESC_CAP = 200


def _is_server_tool(tool: dict) -> bool:
    t = tool.get("type")
    if not isinstance(t, str):
        return False
    if t in _SERVER_TOOL_TYPES:
        return True
    return bool(_DATED_TOOL_RE.match(t))


def _inject_server_tool_schema(tool: dict) -> dict:
    """Injects the implicit schema for Anthropic's server tools so NIM models can use them."""
    t_type = str(tool.get("type", ""))
    t_name = tool.get("name", "")

    # Base copy
    out = dict(tool)
    out["type"] = "function"

    if "bash" in t_type or t_name == "bash":
        out["name"] = t_name or "bash"
        out["description"] = "Run bash commands in a stateful shell."
        out["input_schema"] = {
            "type": "object",
            "properties": {"command": {"type": "string"}, "restart": {"type": "boolean"}},
        }
    elif "computer" in t_type or t_name == "computer":
        out["name"] = t_name or "computer"
        out["description"] = "Control the computer keyboard and mouse."
        out["input_schema"] = {
            "type": "object",
            "properties": {
                "action": {
                    "type": "string",
                    "enum": [
                        "key",
                        "type",
                        "mouse_move",
                        "left_click",
                        "left_click_drag",
                        "right_click",
                        "middle_click",
                        "double_click",
                        "screenshot",
                        "cursor_position",
                    ],
                },
                "coordinate": {"type": "array", "items": {"type": "integer"}},
                "text": {"type": "string"},
            },
            "required": ["action"],
        }
    elif "text_editor" in t_type or t_name == "str_replace_editor":
        out["name"] = t_name or "str_replace_editor"
        out["description"] = "View and edit files using string replacement."
        out["input_schema"] = {
            "type": "object",
            "properties": {
                "command": {
                    "type": "string",
                    "enum": ["view", "create", "str_replace", "insert", "undo_edit"],
                },
                "path": {"type": "string"},
                "file_text": {"type": "string"},
                "insert_line": {"type": "integer"},
                "new_str": {"type": "string"},
                "old_str": {"type": "string"},
                "view_range": {"type": "array", "items": {"type": "integer"}},
            },
            "required": ["command", "path"],
        }

    return out


def anthropic_tools_to_openai(
    tools: list[dict] | None,
    *,
    tool_id_map: "ToolIdMap | None" = None,
    max_tools: int | None = None,
    description_cap: int = _DEFAULT_DESC_CAP,
) -> list[dict]:
    """Anthropic tool defs → OpenAI function-tool defs.

    - Injects schemas for Anthropic server tools (web_search, bash, computer, …) so they work on NIM.
    - Sanitizes names and JSON schemas for NIM compatibility.
    - Optionally caps total tool count and per-tool description length.
    """
    out: list[dict] = []
    renamed: list[tuple[str, str]] = []
    skipped_nameless = 0
    seen_sanitized: dict[str, str] = {}
    collisions: list[tuple[str, str]] = []

    for t in tools or []:
        if _is_server_tool(t):
            _log.debug("tools.server_tool_dropped", type=t.get("type"), name=t.get("name"))
            continue

        ttype = t.get("type")
        if ttype is not None and ttype not in _PASSTHROUGH_TOOL_TYPES:
            _log.debug("tools.unknown_type", type=ttype, name=t.get("name"))
        raw_name = t.get("name")
        if not raw_name:
            skipped_nameless += 1
            continue

        name = sanitize_tool_name(raw_name)
        if name != raw_name:
            renamed.append((raw_name, name))
            if tool_id_map is not None:
                tool_id_map.register_tool_rename(raw_name, name)
        # Collision detection: two distinct original names mapping to the same
        # sanitized name would make tool_result matching ambiguous.
        if name in seen_sanitized:
            if seen_sanitized[name] != raw_name:
                collisions.append((raw_name, seen_sanitized[name]))
                continue  # Drop the later duplicate to preserve determinism.
        else:
            seen_sanitized[name] = raw_name
        desc = t.get("description", "") or ""
        if description_cap and len(desc) > description_cap:
            desc = truncate_description(desc, description_cap)
        schema = sanitize_input_schema(
            t.get("input_schema") or {"type": "object", "properties": {}}
        )
        out.append(
            {
                "type": "function",
                "function": {
                    "name": name,
                    "description": desc,
                    "parameters": schema,
                },
            }
        )

    if max_tools is not None and len(out) > max_tools:
        _log.warning(
            "tools.truncated",
            kept=max_tools,
            dropped=len(out) - max_tools,
        )
        out = out[:max_tools]
    if renamed:
        _log.debug("tools.names_sanitized", renames=renamed[:10], total=len(renamed))
    if skipped_nameless:
        _log.warning("tools.nameless_skipped", count=skipped_nameless)
    if collisions:
        _log.warning(
            "tools.name_collision_dropped",
            collisions=[{"dropped": d, "kept": k} for d, k in collisions],
        )
    return out


def anthropic_tool_choice_to_openai(tc: Any) -> Any:
    if tc is None:
        return None
    if isinstance(tc, str):
        return tc  # pass "auto"/"none" unchanged
    t = tc.get("type")
    if t == "auto":
        return "auto"
    if t == "any":
        return "required"
    if t == "none":
        return "none"
    if t == "tool":
        return {
            "type": "function",
            "function": {"name": sanitize_tool_name(tc.get("name", ""))},
        }
    return "auto"


class ToolIdMap:
    """Bidirectional map between Anthropic `toolu_…` and OpenAI `call_…` ids.

    Anthropic ids survive the whole conversation; OpenAI ids are per-response.
    We preserve the Anthropic id whenever possible by using it as the OpenAI id too.
    """

    def __init__(self) -> None:
        self._a_to_o: dict[str, str] = {}
        self._o_to_a: dict[str, str] = {}
        # Map sanitized-name → original-name so tool_use blocks can emit the
        # name Claude Code originally sent (preserves tool_result matching).
        self._sanitized_to_original: dict[str, str] = {}
        # Track the global order of tool_use IDs encountered in assistant messages.
        self._call_order: list[str] = []

    def record_call_order(self, toolu_id: str) -> None:
        """Record that a tool was called, to preserve ordering in results."""
        if toolu_id not in self._call_order:
            self._call_order.append(toolu_id)

    def get_call_index(self, toolu_id: str) -> int:
        """Return the order index of a tool_use ID, or a large number if unknown."""
        try:
            return self._call_order.index(toolu_id)
        except ValueError:
            return 999999

    def register_anthropic(self, toolu_id: str) -> str:
        self._a_to_o[toolu_id] = toolu_id
        self._o_to_a[toolu_id] = toolu_id
        self.record_call_order(toolu_id)
        return toolu_id

    def openai_to_anthropic(self, openai_id: str) -> str:
        if openai_id in self._o_to_a:
            return self._o_to_a[openai_id]
        a = openai_id if openai_id.startswith("toolu_") else new_tool_use_id()
        self._a_to_o[a] = openai_id
        self._o_to_a[openai_id] = a
        return a

    def anthropic_to_openai(self, toolu_id: str) -> str:
        return self._a_to_o.get(toolu_id, toolu_id)

    def register_tool_rename(self, original: str, sanitized: str) -> None:
        self._sanitized_to_original[sanitized] = original

    def original_tool_name(self, sanitized: str) -> str:
        return self._sanitized_to_original.get(sanitized, sanitized)

    def to_dict(self) -> dict[str, Any]:
        return {
            "a_to_o": self._a_to_o,
            "o_to_a": self._o_to_a,
            "sanitized_to_original": self._sanitized_to_original,
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> ToolIdMap:
        instance = cls()
        instance._a_to_o = data.get("a_to_o", {})
        instance._o_to_a = data.get("o_to_a", {})
        instance._sanitized_to_original = data.get("sanitized_to_original", {})
        return instance
