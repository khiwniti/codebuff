# Codebuff Agent Development Guide

This guide provides essential information for AI coding agents working in the Codebuff repository.

## Build, Lint & Test Commands

### Monorepo Commands (from root)

```bash
bun install                    # Install all dependencies
bun run typecheck              # Type check all packages
bun test                       # Run all tests across packages
bun run format                 # Format all files with Prettier
```

### Development

```bash
bun run dev                    # Start CLI (recommended for development)
bun run start-web              # Start Next.js web app (requires Docker for DB)
bun run start-cli              # Start CLI client
bun run start-db               # Start PostgreSQL database
bun run start-studio           # Open Drizzle Studio (DB GUI)
bun up                         # Start all services
bun down                       # Stop all services
bun ps                         # Check service status
```

### Package-Specific Commands

```bash
# Web package (Next.js)
cd web
bun run dev                    # Start dev server
bun run build                  # Production build
bun run lint                   # Run ESLint
bun run test                   # Run Jest unit tests
bun run test:watch             # Watch mode for tests
bun run e2e                    # Run Playwright E2E tests
bun run e2e:ui                 # E2E tests with UI
bun run typecheck              # Type check

# CLI package
cd cli
bun test                       # Run Bun tests
bun run typecheck              # Type check

# Agent Runtime package
cd packages/agent-runtime
bun test                       # Run tests
bun run typecheck              # Type check

# SDK package
cd sdk
bun test                       # Run tests
bun run release                # Build and publish SDK
```

### Running Single Tests

```bash
# Bun test (used in most packages)
bun test path/to/file.test.ts                    # Run specific test file
bun test --test-name-pattern "test name"         # Run specific test by name

# Jest (web package)
cd web
bun run test path/to/file.test.ts                # Run specific test file
bun run test -- --testNamePattern="test name"    # Run specific test
```

## Project Structure

```
codebuff/
├── agents/              # Agent definition files
├── cli/                 # CLI application (TUI using @opentui)
├── web/                 # Next.js web app & dashboard
├── sdk/                 # TypeScript SDK for programmatic use
├── packages/
│   ├── agent-runtime/   # Core agent execution engine
│   ├── billing/         # Billing & credits system
│   ├── internal/        # Internal packages (DB, auth, etc.)
│   ├── bigquery/        # BigQuery analytics
│   └── code-map/        # Code mapping utilities
├── common/              # Shared code, types, utilities
├── evals/               # Evaluation framework & benchmarks
└── scripts/             # Build & deployment scripts
```

## Code Style Guidelines

### TypeScript Configuration

- **Strict mode enabled**: All code must pass strict type checking
- **ES2022 target** with ESNext modules
- **No implicit returns**: Functions must explicitly return
- **Module resolution**: `bundler` mode for Bun compatibility

### Import Style

```typescript
// ✅ DO: Use specific named imports
import { something } from 'module'
import type { SomeType } from './types'

// ✅ DO: Use type imports with consistent-type-imports
import type { Type1, Type2 } from './types'

// ❌ DON'T: Use namespace imports
import * as everything from 'module'

// ❌ DON'T: Mix value and type imports (ESLint will warn)
import { value, type SomeType } from './module'
```

### Import Order (enforced by ESLint)

```typescript
// 1. Built-in Node modules
import fs from 'fs'
import path from 'path'

// 2. External dependencies
import { QueryClient } from '@tanstack/react-query'
import React from 'react'

// 3. Internal packages (@codebuff/*)
import { getProcessEnv } from '@codebuff/common/env-process'
import { CodebuffClient } from '@codebuff/sdk'

// 4. Relative imports (parent, sibling, index)
import { helper } from '../utils'
import { Component } from './component'

// 5. Type imports
import type { AgentDefinition } from './types'
```

### Formatting (Prettier)

- **2 spaces** for indentation
- **No semicolons**
- **Single quotes** for strings
- **Trailing commas** in objects/arrays
- Run `bun run format` before committing

### Naming Conventions

```typescript
// camelCase for variables, functions, methods
const userName = 'john'
function getUserData() {}

// PascalCase for types, interfaces, classes, React components
type UserData = { name: string }
interface UserProps {
  id: string
}
class UserService {}
const UserCard = () => {}

// SCREAMING_SNAKE_CASE for constants
const API_URL = 'https://api.example.com'
const MAX_RETRIES = 3

// kebab-case for file names
user - service.ts
api - client.ts
```

### Environment Variables

```typescript
// ✅ DO: Use package-specific env helpers
// In CLI:
import { getCliEnv } from './utils/env'
const env = getCliEnv()

// In SDK:
import { getSdkEnv } from './env'
const env = getSdkEnv()

// In Web:
import { env } from '@codebuff/common/env'

// ❌ DON'T: Use ProcessEnv directly in CLI or SDK
// ESLint will enforce this - use CliEnv or SdkEnv types instead
import { getProcessEnv } from '@codebuff/common/env-process' // ❌ Error in CLI/SDK
```

### Error Handling

```typescript
// ✅ DO: Use try-catch for async operations
try {
  const result = await someAsyncOperation()
  return result
} catch (error) {
  logger.error('Operation failed', { error })
  throw new Error('Meaningful error message')
}

// ✅ DO: Type error objects when possible
catch (error) {
  if (error instanceof SpecificError) {
    // Handle specific error
  }
  throw error
}
```

### Async/Await Patterns

```typescript
// ✅ DO: Use async/await consistently
async function fetchData() {
  const data = await api.getData()
  return data
}

// ✅ DO: Use async generators for streams
async function* processStream() {
  for await (const chunk of stream) {
    yield processChunk(chunk)
  }
}

// ❌ DON'T: Mix .then() with async/await
async function badExample() {
  return api.getData().then((data) => data) // Use await instead
}
```

### Testing with Bun

```typescript
import {
  describe,
  it,
  expect,
  beforeEach,
  afterEach,
  spyOn,
  mock,
} from 'bun:test'

describe('MyComponent', () => {
  beforeEach(() => {
    // Setup
  })

  afterEach(() => {
    // Cleanup - always restore mocks
    mock.restore()
  })

  it('should do something', () => {
    // ✅ DO: Use spyOn for mocking
    const spy = spyOn(myModule, 'myFunction').mockReturnValue('mocked')

    const result = myComponent()

    expect(spy).toHaveBeenCalled()
    expect(result).toBe('expected')
  })
})
```

## Common Patterns

### Lodash Usage

```typescript
// Import specific functions
import { uniq, debounce, isNil } from 'lodash'

const uniqueItems = uniq(array)
```

### Pattern Matching (ts-pattern)

```typescript
import { match } from 'ts-pattern'

const result = match(value)
  .with({ type: 'success' }, (v) => handleSuccess(v))
  .with({ type: 'error' }, (v) => handleError(v))
  .otherwise(() => handleDefault())
```

## Git Workflow

### Commit Messages (Conventional Commits)

```
feat: add new agent for React component generation
fix: resolve WebSocket connection timeout
docs: update API documentation
test: add unit tests for file operations
refactor: simplify error handling logic
chore: update dependencies
```

### Before Committing

```bash
bun run typecheck              # Ensure no type errors
bun test                       # Run all tests
bun run format                 # Format code
```

## Key Dependencies

- **Runtime**: Bun ^1.3.5 (NOT Node.js)
- **React**: 18.3.1 (web), 19.0.0 (cli with @opentui)
- **Next.js**: 15.5.9
- **TypeScript**: 5.5.4
- **Testing**: Bun test (packages), Jest (web), Playwright (E2E)

## Additional Resources

- [Contributing Guide](./CONTRIBUTING.md) - Development setup
- [README](./README.md) - Project overview
- [Codebuff Docs](https://codebuff.com/docs) - Official documentation
- [Discord](https://codebuff.com/discord) - Community support
