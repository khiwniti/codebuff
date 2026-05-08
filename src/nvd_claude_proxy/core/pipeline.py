from __future__ import annotations

from typing import Any, Iterable

from .events import RawOpenAIChunk, TranslatedEvent, StreamState, StreamProcessor


class Pipeline:
    """Orchestrates a sequence of processors."""

    def __init__(self, processors: list[StreamProcessor], state: StreamState) -> None:
        self.processors = processors
        self.state = state

    def feed(self, chunk: dict[str, Any]) -> Iterable[TranslatedEvent]:
        """Feed a raw OpenAI chunk through the processor chain."""
        raw = RawOpenAIChunk(chunk)
        for processor in self.processors:
            # We don't break early here so every processor sees the chunk
            # before Finalizer might mark the state as finished.
            yield from processor.process(raw, self.state)
            if self.state.finished:
                # But we break if a processor (like Safety or Finalizer)
                # explicitly finished the stream for this chunk.
                break

    def finalize(self) -> Iterable[TranslatedEvent]:
        """Ensure the stream is properly closed if not already finished."""
        if not self.state.finished:
            for processor in self.processors:
                if hasattr(processor, "finalize"):
                    yield from processor.finalize(self.state)  # type: ignore
                    break
            self.state.finished = True
