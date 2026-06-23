# Openbuff CLI - Standalone Version

A simple AI coding assistant CLI using NVIDIA NIM API.

## Installation

```bash
npm install -g openbuff
```

## Usage

```bash
# Configure API key
openbuff init

# Run AI assistant
openbuff "Fix the bug in auth.js"
```

## Features

- Simple console output
- NVIDIA NIM powered
- No authentication required

## Full TUI Version

For the full terminal UI with OpenTUI (similar to GitHub Copilot), run the main CLI:

```bash
# From the repository
cd /workspace/project/cli
bun run dev
```

This launches the React-based terminal interface with:
- Rich formatting
- Syntax highlighting  
- Mouse support
- Chat history
- Multiple model support