# Openbuff Configuration Summary

## NPM Published Packages

| Package | Version | Install Command |
|---------|---------|-----------------|
| `openbuff` (standalone CLI) | 1.2.0 | `npm install -g openbuff` |
| `@khiwniti/sdk` | 1.0.1 | `npm install @khiwniti/sdk` |
| `@khiwniti/openbuff-common` | 1.0.1 | `npm install @khiwniti/openbuff-common` |
| `@khiwniti/agents` | 1.0.0 | `npm install @khiwniti/agents` |
| `@khiwniti/agent-runtime` | 1.0.0 | `npm install @khiwniti/agent-runtime` |
| `@khiwniti/code-map` | 1.0.0 | `npm install @khiwniti/code-map` |
| `@khiwniti/llm-providers` | 1.0.0 | `npm install @khiwniti/llm-providers` |
| `@khiwniti/evals` | 1.0.0 | `npm install @khiwniti/evals` |
| `@khiwniti/freebuff` | 1.0.0 | `npm install @khiwniti/freebuff` |
| `@khiwniti/cli` | 1.0.0 | `npm install @khiwniti/cli` |

## CLI Usage

### Standalone CLI (Simple)
```bash
npm install -g openbuff
openbuff --help
```

### Full TUI CLI (Development)
```bash
cd cli
FREEBUFF_MODE=true bun run dev
```

## Environment Variables for TUI

| Variable | Description | Example |
|----------|-------------|---------|
| `NEXT_PUBLIC_CB_ENVIRONMENT` | Environment mode | `prod` |
| `NEXT_PUBLIC_CODEBUFF_APP_URL` | Backend URL | `https://openbuff.dev` |
| `NEXT_PUBLIC_SUPPORT_EMAIL` | Support email | `support@openbuff.dev` |
| `NEXT_PUBLIC_POSTHOG_API_KEY` | Analytics key | (dummy for freebuff) |
| `NEXT_PUBLIC_POSTHOG_HOST_URL` | Analytics host | `https://posthog.openbuff.dev` |
| `FREEBUFF_MODE` | Enable freebuff mode | `true` |

## Build Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start CLI in dev mode (TUI) |
| `npm run dev:freebuff` | Start CLI in freebuff mode |
| `npm run build:sdk` | Build SDK package |
| `npm run build:freebuff` | Build freebuff binary |

## Configuration Files

- `/workspace/project/cli/src/index.tsx` - CLI entry point with TUI initialization
- `/workspace/project/cli/src/app.tsx` - Main React application
- `/workspace/project/openbuff-cli/bin/openbuff.js` - Standalone CLI script
- `/workspace/project/sdk/src/` - SDK source with OpenbuffClient export

## DeepWiki Reference

For detailed architecture documentation, see:
- https://deepwiki.com/CodebuffAI/codebuff/2.1-cli-application
- https://deepwiki.com/CodebuffAI/codebuff/7.1-development-environment