# nvd-claude-proxy

[![PyPI](https://img.shields.io/pypi/v/nvd-claude-proxy)](https://pypi.org/project/nvd-claude-proxy/)
[![Python](https://img.shields.io/pypi/pyversions/nvd-claude-proxy)](https://pypi.org/project/nvd-claude-proxy/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Code Style: Ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)

**Run Claude Code — and any Anthropic SDK client — on enterprise-grade NVIDIA NIM models.**

`nvd-claude-proxy` is a production-hardened local HTTP proxy that translates between the [Anthropic Messages API](https://docs.anthropic.com/en/api/messages) and the NVIDIA NIM (OpenAI-compatible) API. It enables you to run **Claude Code**, the Anthropic SDK, and other clients using high-performance NVIDIA-hosted models with official-grade resilience and scaling.

---

## 🚀 Key Features

- **Architectural Excellence**: Fully decoupled core translation logic from the transport layer.
- **Enterprise Resilience**: Built-in **Circuit Breakers** and automated failover chains to protect against upstream outages.
- **Idempotency Support**: Request deduplication and safe retries via `anthropic-idempotency-key` across Redis, SQLite, and Memory backends.
- **Scalable State**: Distributed session management via **Redis** (with SQLite and In-Memory fallbacks).
- **Official-Grade Security**: Unified `AuthMiddleware` protecting all endpoints with global API key enforcement.
- **Claude Code Optimized**: Specifically tuned for Claude Code's complex tool-calling and reasoning patterns.
- **Vision & Progressive Streaming**: Fine-grained progressive tool streaming and real-time multimodal (`image_url`) parity.
- **Modular Pipeline**: Event-driven streaming architecture for deterministic state management.

---

## 🛠 Deployment & Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NVIDIA_API_KEY` | (Required) | Your NVIDIA NIM API key. |
| `PROXY_API_KEY` | None | Optional key to protect the proxy itself. |
| `STORAGE_ENGINE` | `sqlite` | Persistence backend: `redis`, `sqlite`, or `memory`. |
| `REDIS_URL` | None | Required if `STORAGE_ENGINE=redis` (e.g., `redis://localhost:6379`). |
| `PROXY_PORT` | `8788` | Local port for the proxy. |
| `RATE_LIMIT_RPM`| `0` | Global rate limit (requests per minute). `0` to disable. |

### Quick Start

```bash
# Install the proxy
pip install nvd-claude-proxy[full]

# Export your API key
export NVIDIA_API_KEY=nvapi-...

# Run the proxy
ncp run
```

Then point your Claude Code at the proxy:
```bash
export ANTHROPIC_BASE_URL=http://localhost:8788
claude
```

---

## 🏗 Architecture

The proxy uses a **Chain of Responsibility** pattern for streaming events:
`MetadataProcessor -> TextProcessor -> ToolProcessor -> SafetyProcessor -> FinalizerProcessor`

This ensures that even complex interleaved reasoning and parallel tool calls are correctly reconstructed for the Anthropic SDK.

---
**Official-Grade Infrastructure for the AI Era.**
