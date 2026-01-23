# Quick MCP Reference

## Installed Agents

### Sequential Thinking Agent

- **Package:** `@modelcontextprotocol/server-sequential-thinking`
- **Setup:** None required ✓
- **Use case:** Complex problem solving, planning, debugging

### Railway Agent

- **Package:** `@railway/mcp-server`
- **Setup:** Option A: `railway login` (recommended) OR Option B: Set `RAILWAY_TOKEN`
- **Use case:** Deploy and manage Railway services

## Quick Start

```bash
# 1. Authenticate with Railway (choose one method)
# Method A (recommended): Use Railway CLI
railway login

# Method B: Set Railway token
export RAILWAY_TOKEN="your-token-here"

# 2. Start Codebuff
codebuff

# 3. Use agents with @ syntax
@Sequential Thinking Agent how do I architect this system?
@Railway Agent list my projects
```

## Getting Railway Token

1. Go to https://railway.app/account/tokens
2. Click "Create Token"
3. Copy the token
4. Add to shell config:
   ```bash
   echo 'export RAILWAY_TOKEN="your-token"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Files Created

- `.agents/sequential-thinking.ts` - Sequential thinking agent
- `.agents/railway.ts` - Railway deployment agent
- `.agents/MCP_SETUP.md` - Detailed setup guide
- `.agents/MCP_QUICK_REF.md` - This file

## Examples

### Sequential Thinking

```
@Sequential Thinking Agent I need to migrate 1TB of data from MySQL to PostgreSQL
with zero downtime. What's the best approach?
```

### Railway

```
@Railway Agent show me all services in my production project

@Railway Agent deploy the latest commit to the api service

@Railway Agent what's the current status of my web service?
```

## Troubleshooting

| Issue              | Solution                                               |
| ------------------ | ------------------------------------------------------ |
| Agent not found    | Restart Codebuff CLI                                   |
| Railway auth error | Check `echo $RAILWAY_TOKEN` is set                     |
| MCP server timeout | Check internet connection (npx downloads on first use) |

## Learn More

- Full docs: `.agents/MCP_SETUP.md`
- MCP Registry: https://github.com/modelcontextprotocol/servers
- Railway Docs: https://docs.railway.app
