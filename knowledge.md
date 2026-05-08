# Codebuff — Project Knowledge

Codebuff is an open-source, multi-agent AI coding assistant (CLI + SDK + web API). Freebuff is a free, ad-supported variant built from the same CLI.

This file gives Codebuff (and other AI tools) context to work in this repo effectively. For deeper details, always consult `docs/` (see "Docs" section below) before making non-trivial changes.

## Quickstart

Requires **Bun 1.3.11** (see `package.json` `engines`). Bun is both the runtime and the package manager — avoid `npm`/`yarn`/`pnpm`.

```bash
bun install                 # install all workspace deps
bun up                      # start web server + local Postgres (Docker)
bun start-cli               # start the CLI (in a separate terminal)
bun ps                      # list running dev services
bun down                    # stop all dev services
```

Common workflows:

```bash
bun dev                     # alias for start-cli
bun start-web               # start DB + Next.js web app
bun start-studio            # open Drizzle Studio for DB inspection
bun dev:freebuff            # run the CLI in FREEBUFF_MODE
```

## Commands

- **Typecheck (all packages):** `bun typecheck`
- **Tests (all packages):** `bun test`
- **Tests (single package):** `bun --cwd <pkg> test` (e.g. `bun --cwd cli test`)
- **Format:** `bun format` (Prettier on `**/*.{ts,tsx,json,md}`)
- **Clean TS build + node_modules:** `bun clean-ts`
- **Generate tool definitions:** `bun generate-tool-definitions`
- **Release CLI / SDK / Freebuff:** `bun release:cli` / `bun release:sdk` / `bun release:freebuff`

Running scripts against prod uses Infisical:

```bash
infisical run --env=prod -- bun scripts/<name>.ts
```

Default env is `dev`; always pass `--env=prod` explicitly. Prefer read-only queries.

## Architecture

TypeScript monorepo using **Bun workspaces**. High-level dependency flow:

```
cli  ──▶  sdk  ──▶  agent-runtime  ──▶  common
                         ▲                  ▲
                         └─ agents ─────────┘
web ──▶ common, internal, billing, bigquery
```

### Key packages

- `cli/` — TUI client (OpenTUI + React). Entry: `src/index.tsx` → `app.tsx` → `chat.tsx`. Handles UI, slash commands, auth, and streams events from the SDK.
- `sdk/` — Public `@codebuff/sdk`. Entry: `src/client.ts` (`CodebuffClient`) → `src/run.ts`. Executes tool calls **locally** on the user's machine.
- `packages/agent-runtime/` — Agent loop (LLM call → tool calls → repeat). Entry: `src/main-prompt.ts` → `src/run-agent-step.ts` (`loopAgentSteps()`). Handles subagent spawning and `handleSteps` generators.
- `common/` — Shared types, Zod schemas, tool definitions, constants, error utils, DI contracts (`src/types/contracts/`). Leaf package — depends on nothing.
- `agents/` — Agent definitions shipped with Codebuff (base2, editor, file-explorer, thinker, reviewer, researcher, basher, context-pruner, etc.).
- `.agents/` — Project-local agent templates (claude-code-cli, codex-cli, gemini-cli, codebuff-local-cli, glm-nvidia, notion agents, etc.).
- `web/` — Next.js app + REST API. Notable routes: `src/app/api/v1/chat/completions/` (LLM proxy), `/api/auth/` (NextAuth), `/api/stripe/`, `/api/agents/`, `/api/orgs/`.
- `packages/internal/` — Server-side utilities: Drizzle ORM (`src/db/schema.ts`), env validation, Loops email, forked OpenAI-compatible + OpenRouter AI SDK providers.
- `packages/billing/` — Credits, subscriptions, auto-topup, usage aggregation.
- `packages/bigquery/` — Analytics traces + relabel data.
- `packages/code-map/` — Tree-sitter parser for `read_subtree` (TS/JS/Python/Go/Rust/Java/C/C++/C#/Ruby/PHP).
- `evals/` — BuffBench evaluation harness. Runs Codebuff / Claude Code / Codex against real-world tasks.
- `freebuff/` — Free tier. `freebuff/cli/` (standalone binary) + `freebuff/web/` (auth). Uses ChatGPT OAuth for LLM access.
- `scripts/` — Dev tooling, analytics (DAU/MRR/usage), service management, release helpers.
- `docs/` — Authoritative docs (see below).

### Data flow

1. User types a prompt in the `cli/` TUI.
2. CLI calls `client.run()` in `sdk/`.
3. SDK creates a session state and streams tool calls via `callMainPrompt()` in `agent-runtime/`.
4. The agent loop calls the LLM (via Codebuff backend at `web/src/app/api/v1/chat/completions/`, ChatGPT OAuth, or Claude OAuth).
5. The runtime emits tool calls; the SDK executes them **locally** (file edits, terminal, code search).
6. Results stream back to the CLI for rendering.

See `docs/request-flow.md` for the full lifecycle.

## Conventions

- **Package manager:** Bun only (`bun install`, `bun run`, `bun --cwd <pkg> ...`). Never `npm`/`yarn`/`pnpm`.
- **Node/Bun version:** Pinned to `bun@1.3.11` via `packageManager` + `engines`.
- **TypeScript:** Strict. No `as any` — use precise types or proper generics.
- **Formatting:** Prettier (config in `.prettierrc`). Run `bun format`.
- **Error handling:** Prefer the `ErrorOr<T>` pattern (`success(value)` / `failure(error)`) from `common/src/util/error.ts` over throwing.
- **Dependency injection:** Cross-package function calls go through **contracts** in `common/src/types/contracts/` (`database.ts`, `llm.ts`, `analytics.ts`, `client.ts`, `env.ts`). This keeps `agent-runtime` usable from both the SDK and server.
- **Testing:** Prefer DI over mocking. Mock factories live in `common/src/testing/`. See `docs/testing.md`.
- **Env vars:** Validate with `@t3-oss/env-nextjs`. Server env lives in `packages/internal/src/env.ts`. Never read `process.env.*` directly in library code — go through the contract. See `docs/environment-variables.md`.
- **Database:** Drizzle ORM. Edit `packages/internal/src/db/schema.ts` using the TS DSL — do **not** hand-write migration SQL. Use the internal scripts to generate/apply migrations.
- **Git:** Never force-push `main` unless explicitly requested. Run interactive git commands (anything that opens an editor or prompts) inside tmux.
- **Retrieval over guessing:** Always read the relevant file in `docs/` before non-trivial changes. Prefer looking up actual usage in the codebase over assuming APIs.

## Gotchas

- **Services must run in order:** `bun up` starts Docker Postgres + web; run it before `bun start-cli` when developing end-to-end.
- **Logs:** Dev service logs land in `debug/console/` (`db.log`, `studio.log`, `sdk.log`, `web.log`). CLI tmux session captures go to `debug/tmux-sessions/{session}/`.
- **Worktrees:** To run multiple stacks in parallel, set `PORT` / `NEXT_PUBLIC_WEB_PORT` / `NEXT_PUBLIC_CODEBUFF_APP_URL` in `.env.development.local`. Helpers: `bun init-worktree`, `bun cleanup-worktree`.
- **Prod scripts:** Scripts connect to whatever env Infisical injects. Default is `dev`. Always pass `--env=prod` explicitly; coordinate before running writes.
- **Tool execution is local:** Tool calls run on the user's machine via the SDK, not on the server. Keep this in mind when designing new tools.
- **Two product builds from one CLI:** `FREEBUFF_MODE=true` flips the CLI into Freebuff behavior. Don't fork code — respect the flag.
- **Visual CLI bugs:** Unit tests and typechecks won't catch layout/rendering issues. Use the `codebuff-local-cli` agent (tmux-based E2E) after touching `cli/src/components/` or `cli/src/hooks/`.
- **Test scope:** Prefer `bun --cwd <pkg> test` while iterating — the full `bun test` covers all workspaces and is slow.

## Docs (read before changing related code)

- `docs/architecture.md` — Package graph, per-package details, architectural patterns
- `docs/request-flow.md` — Full request lifecycle CLI ↔ server
- `docs/error-schema.md` — Server error response formats + client-side handling
- `docs/development.md` — Dev setup, worktrees, logs, DB migrations
- `docs/testing.md` — DI-over-mocking philosophy, tmux CLI testing
- `docs/environment-variables.md` — Env var rules, DI helpers, loading order
- `docs/agents-and-tools.md` — Agent system, shell shims, tool definitions
- `docs/authentication.md` — Auth flows (GitHub OAuth, Claude OAuth, ChatGPT OAuth)
- `docs/freebuff-waiting-room.md` — Freebuff-specific flows

## Goal

Make an efficient learning agent that can do anything.
