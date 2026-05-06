from __future__ import annotations

from dataclasses import dataclass


@dataclass(slots=True)
class ToolAccumulator:
    """Accumulator for a single streamed OpenAI tool call."""

    openai_id: str | None = None
    name: str | None = None
    arguments: str = ""
    anthropic_id: str | None = None
    anth_index: int | None = None
    started: bool = False
    closed: bool = False
