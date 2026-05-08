from __future__ import annotations

from nvd_claude_proxy.core.events import StreamState
from nvd_claude_proxy.core.pipeline import Pipeline
from nvd_claude_proxy.core.processors import (
    MetadataProcessor,
    TextProcessor,
    ToolProcessor,
    SafetyProcessor,
    FinalizerProcessor,
)
from nvd_claude_proxy.translators.tool_translator import ToolIdMap
from nvd_claude_proxy.translators.tool_controller import ToolInvocationController
from nvd_claude_proxy.config.models import CapabilityManifest


def _collect(chunks, tool_schemas=None):
    spec = CapabilityManifest(alias="claude-opus-4-7", nvidia_id="nvidia/big")
    tool_id_map = ToolIdMap()
    tool_controller = ToolInvocationController(
        spec,
        tool_id_map,
        tool_schemas=tool_schemas or {},
    )
    state = StreamState(
        message_id="msg_test",
        model_name="claude-opus-4-7",
    )
    pipeline = Pipeline(
        processors=[
            MetadataProcessor(),
            TextProcessor(),
            ToolProcessor(tool_id_map, tool_controller),
            SafetyProcessor(),
            FinalizerProcessor(),
        ],
        state=state,
    )

    events = []
    for c in chunks:
        for ev in pipeline.feed(c):
            events.append({"event": ev.event, "data": ev.data})

    for ev in pipeline.finalize():
        events.append({"event": ev.event, "data": ev.data})

    return events


def test_pure_text_stream():
    chunks = [
        {
            "choices": [
                {"index": 0, "delta": {"role": "assistant", "content": ""}, "finish_reason": None}
            ]
        },
        {"choices": [{"index": 0, "delta": {"content": "Hello"}, "finish_reason": None}]},
        {"choices": [{"index": 0, "delta": {"content": " world"}, "finish_reason": None}]},
        {"choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}]},
        {"choices": [], "usage": {"prompt_tokens": 5, "completion_tokens": 2}},
    ]
    events = _collect(chunks)
    names = [e["event"] for e in events]
    assert names[0] == "message_start"
    assert names[-2:] == ["message_delta", "message_stop"]
    assert any(
        e["event"] == "content_block_delta" and e["data"]["delta"]["type"] == "text_delta"
        for e in events
    )


def test_reasoning_then_text():
    chunks = [
        {
            "choices": [
                {"index": 0, "delta": {"reasoning_content": "Thinking..."}, "finish_reason": None}
            ]
        },
        {"choices": [{"index": 0, "delta": {"content": "Hello"}, "finish_reason": "stop"}]},
    ]
    events = _collect(chunks)
    types = []
    for e in events:
        if e["event"] == "content_block_start":
            types.append(e["data"]["content_block"]["type"])

    assert "thinking" in types
    assert "text" in types
    # Thinking must come before text in this sequence
    assert types.index("thinking") < types.index("text")


def test_tool_call_stream():
    chunks = [
        {
            "choices": [
                {
                    "index": 0,
                    "delta": {
                        "tool_calls": [
                            {
                                "index": 0,
                                "id": "call_1",
                                "type": "function",
                                "function": {"name": "get_weather", "arguments": ""},
                            }
                        ]
                    },
                    "finish_reason": None,
                }
            ]
        },
        {
            "choices": [
                {
                    "index": 0,
                    "delta": {
                        "tool_calls": [
                            {"index": 0, "function": {"arguments": '{"city": "London"}'}}
                        ]
                    },
                    "finish_reason": "tool_calls",
                }
            ]
        },
    ]
    events = _collect(chunks)
    names = [e["event"] for e in events]
    assert "content_block_start" in names
    assert any(
        e["event"] == "content_block_start" and e["data"]["content_block"]["type"] == "tool_use"
        for e in events
    )
    assert any(
        e["event"] == "content_block_delta" and e["data"]["delta"]["type"] == "input_json_delta"
        for e in events
    )
