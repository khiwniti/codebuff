# Openbuff - AI Coding Assistant with NVIDIA NIM

Openbuff is a powerful CLI tool that writes code for you, powered by NVIDIA NIM (NVIDIA Inference Microservices).

## Key Features

- **NVIDIA NIM Integration**: Leverages NVIDIA's inference microservices for fast, efficient AI-powered code generation
- **Understands your whole codebase**: Deep code context awareness
- **Creates and edits multiple files** based on your natural language requests
- **Runs tests, type checkers, and linters** to ensure code quality
- **Powerful iterative approach**: Keep working until it reaches your goals

## Installation

To install Openbuff, run:

```bash
npm install -g openbuff
```

(Use `sudo` if you get a permission error.)

## Usage

After installation, start Openbuff by running:

```bash
openbuff [project-directory]
```

If no project directory is specified, Openbuff will use the current directory.

## Prerequisites

Openbuff uses NVIDIA NIM for inference. You'll need:

1. An NVIDIA API key (get one at https://build.nvidia.com)
2. Set your NVIDIA API key as an environment variable:
   ```bash
   export NVIDIA_API_KEY=your_nvidia_api_key_here
   ```

## Configuration

Openbuff can be configured via environment variables:

| Variable | Description |
|----------|-------------|
| `NVIDIA_API_KEY` | Your NVIDIA NIM API key |
| `OPENBUFF_MODEL` | Model to use (default: nvidia/llama-3.1-nemotron-70b-instruct) |
| `HTTPS_PROXY` | Proxy server URL (if behind a corporate firewall) |

## Publishing to npm

To publish this package to npm:

```bash
cd openbuff/release

# Set your npm token
npm config set //registry.npmjs.org/:_authToken=YOUR_NPM_TOKEN

# Publish
npm publish --access public
```

Or use the included publish script:

```bash
NPM_TOKEN=your_token node publish.js
```

## Knowledge Files

To unlock the full benefits of modern LLMs, we recommend storing knowledge alongside your code. Add a `knowledge.md` file anywhere in your project to provide helpful context, guidance, and tips for the LLM as it performs tasks for you.

## Tips

1. Type '/help' or just '/' to see available commands
2. Create a `knowledge.md` file to collect specific advice for your codebase
3. Type `undo` or `redo` to revert or reapply file changes
4. Press `Esc` or `Ctrl+C` while generating to stop it

## Troubleshooting

### Permission Errors

If you are getting permission errors during installation, try using sudo:

```bash
sudo npm install -g openbuff
```

### Corporate Proxy / Firewall

If you see `Failed to download openbuff: Request timeout`, you may be behind a corporate proxy. Set `HTTPS_PROXY`:

```bash
export HTTPS_PROXY=http://your-proxy-server:port
openbuff
```

## Feedback

Please email your feedback to support@codebuff.com. Thank you for using Openbuff!