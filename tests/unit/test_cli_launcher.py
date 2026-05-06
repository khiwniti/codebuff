from __future__ import annotations

from nvd_claude_proxy.cli.main import _resolve_claude_code_max_output_tokens


def test_claude_code_max_output_defaults_above_model_cap(monkeypatch):
    monkeypatch.delenv("NCP_CLAUDE_CODE_MAX_OUTPUT_TOKENS", raising=False)
    monkeypatch.delenv("CLAUDE_CODE_MAX_OUTPUT_TOKENS", raising=False)

    assert _resolve_claude_code_max_output_tokens(16_384) == "65536"


def test_claude_code_max_output_preserves_larger_parent_value(monkeypatch):
    monkeypatch.delenv("NCP_CLAUDE_CODE_MAX_OUTPUT_TOKENS", raising=False)
    monkeypatch.setenv("CLAUDE_CODE_MAX_OUTPUT_TOKENS", "131072")

    assert _resolve_claude_code_max_output_tokens(16_384) == "131072"


def test_claude_code_max_output_ncp_override_wins(monkeypatch):
    monkeypatch.setenv("NCP_CLAUDE_CODE_MAX_OUTPUT_TOKENS", "98304")
    monkeypatch.setenv("CLAUDE_CODE_MAX_OUTPUT_TOKENS", "131072")

    assert _resolve_claude_code_max_output_tokens(16_384) == "98304"


def test_claude_code_max_output_never_below_model_cap(monkeypatch):
    monkeypatch.setenv("NCP_CLAUDE_CODE_MAX_OUTPUT_TOKENS", "1000")
    monkeypatch.delenv("CLAUDE_CODE_MAX_OUTPUT_TOKENS", raising=False)

    assert _resolve_claude_code_max_output_tokens(16_384) == "16384"
