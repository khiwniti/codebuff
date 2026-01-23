# MCP Servers Setup Guide

This document explains how to use the Sequential Thinking and Railway MCP agents.

## Installed MCP Agents

### 1. Sequential Thinking Agent

**Purpose:** Breaks down complex problems into logical steps and solves them systematically.

**Location:** `.agents/sequential-thinking.ts`

**MCP Server:** `@modelcontextprotocol/server-sequential-thinking`

**Usage:**

```bash
# In Codebuff CLI
@Sequential Thinking Agent how should I architect a microservices system for a social media app?
```

**No setup required** - works out of the box!

---

### 2. Railway Agent

**Purpose:** Manages Railway deployments, services, and infrastructure.

**Location:** `.agents/railway.ts`

**MCP Server:** `@railway/mcp-server`

**Setup Options:**

**Option A: Use Railway CLI Authentication (Recommended)**

- The Railway MCP server will use your Railway CLI credentials
- Make sure you're logged in: `railway login`
- **No additional setup required!**

**Option B: Use API Token (Advanced)**

1. Get your Railway API token from [Railway Dashboard](https://railway.app/account/tokens)
2. Uncomment the `env` section in `.agents/railway.ts`
3. Set the environment variable:
   ```bash
   export RAILWAY_TOKEN="your-railway-token-here"
   ```

**Usage:**

```bash
# In Codebuff CLI
@Railway Agent list my projects

@Railway Agent deploy the api service in my production project

@Railway Agent check the logs for the web service

@Railway Agent set DATABASE_URL environment variable for api service
```

3. Reload your shell:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

**Usage:**

```bash
# In Codebuff CLI
@Railway Agent list my projects

@Railway Agent deploy the api service in my production project

@Railway Agent check the logs for the web service

@Railway Agent set DATABASE_URL environment variable for api service
```

---

## Testing the Agents

### Test Sequential Thinking

```bash
codebuff
> @Sequential Thinking Agent solve this: If I have 3 boxes and each box can hold 5 items, but I need to store 17 items, how many boxes do I need and how should I organize them?
```

### Test Railway (after setting RAILWAY_TOKEN)

```bash
codebuff
> @Railway Agent list all my projects and their services
```

---

## Troubleshooting

### Agent not found

- Restart Codebuff CLI after creating the agent files
- Verify the files are in `.agents/` directory with `.ts` extension

### Railway: "Authentication failed"

- **First, try:** `railway login` to authenticate via Railway CLI
- If using token: Check that `RAILWAY_TOKEN` is set: `echo $RAILWAY_TOKEN`
- Verify your token is valid on [Railway Dashboard](https://railway.app/account/tokens)
- Make sure there are no extra spaces or quotes in the token
- Ensure the `env` section is uncommented in `.agents/railway.ts`

### MCP server fails to start

- The MCP servers are downloaded automatically via `npx`
- Ensure you have internet connection for first use
- Check `bun` or `node` is installed

---

## Customizing the Agents

Edit the agent files to customize behavior:

```typescript
// .agents/sequential-thinking.ts or .agents/railway.ts

const definition: AgentDefinition = {
  model: 'anthropic/claude-sonnet-4', // Change to different model
  systemPrompt: '...', // Customize personality/expertise
  instructionsPrompt: '...', // Change step-by-step instructions
}
```

---

## Adding More MCP Servers

Browse available MCP servers:

- [MCP Server Registry](https://github.com/modelcontextprotocol/servers)
- [NPM Search](https://www.npmjs.com/search?q=mcp-server)

Popular options:

- `@modelcontextprotocol/server-github` - GitHub integration
- `@notionhq/notion-mcp-server` - Notion integration (already in `.agents/notion-agent.ts`)
- `@modelcontextprotocol/server-filesystem` - File system operations
- `@modelcontextprotocol/server-sqlite` - SQLite database access

Follow the same pattern as the Railway agent to add new MCP servers!
