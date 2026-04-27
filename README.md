# nvd-claude-proxy

[![PyPI](https://img.shields.io/pypi/v/nvd-claude-proxy)](https://pypi.org/project/nvd-claude-proxy/)
[![Python](https://img.shields.io/pypi/pyversions/nvd-claude-proxy)](https://pypi.org/project/nvd-claude-proxy/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Tests](https://github.com/khiwn/nvd-claude-proxy/actions/workflows/tests.yml/badge.svg)](https://github.com/khiwn/nvd-claude-proxy/actions/workflows/tests.yml)
[![Code Style: Ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)

**Run Claude Code — and any Anthropic SDK client — on free NVIDIA NIM models.**

A local HTTP proxy that speaks the [Anthropic Messages API](https://docs.anthropic.com/en/api/messages) and forwards requests to `https://integrate.api.nvidia.com/v1` (NVIDIA NIM / build.nvidia.com). Point your `ANTHROPIC_BASE_URL` at the proxy and your tools work unchanged while inference runs on Nemotron Ultra, Qwen3, DeepSeek-R1, or any other NIM model.

---

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#