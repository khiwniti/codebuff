# Railway All Services Fix Strategy

**Date:** 2026-01-23  
**Status:** In Progress - Web deploying, others need cleanup

## Current Situation

### Services Status

```
✅ @codebuff/web          | DEPLOYING (fix applied)
❌ @codebuff/build-tools  | FAILED
❌ @codebuff/agent-runtime| FAILED
❌ @codebuff/code-map     | FAILED
❌ @codebuff/.agents      | FAILED
❌ @codebuff/cli          | FAILED
❌ @codebuff/billing      | FAILED
❌ @codebuff/evals        | FAILED
❌ @codebuff/bigquery     | FAILED
❌ @codebuff/sdk          | FAILED
❌ @codebuff/agents       | FAILED
❌ @codebuff/internal     | FAILED
```

## Root Cause Analysis

Railway auto-detected all **12 workspace packages** as separate services when the project was initialized. However:

- **Only `@codebuff/web` is a deployable service** (Next.js application)
- **All other packages are TypeScript libraries** used internally
- These libraries don't have:
  - Independent build processes
  - Start commands
  - Server functionality
  - A reason to be deployed

## Architectural Understanding

### What Each Package Is

| Package                 | Type        | Purpose                 | Should Deploy?          |
| ----------------------- | ----------- | ----------------------- | ----------------------- |
| **@codebuff/web**       | Next.js App | Web UI & API            | ✅ YES                  |
| @codebuff/cli           | CLI Tool    | Developer tool          | ❌ NO (runs locally)    |
| @codebuff/sdk           | Library     | TypeScript SDK          | ❌ NO (npm package)     |
| @codebuff/internal      | Library     | Shared DB/internal code | ❌ NO (used by web)     |
| @codebuff/agent-runtime | Library     | Agent execution engine  | ❌ NO (used by web/cli) |
| @codebuff/billing       | Library     | Billing logic           | ❌ NO (used by web)     |
| @codebuff/build-tools   | Library     | Build utilities         | ❌ NO (dev dependency)  |
| @codebuff/code-map      | Library     | Code parsing            | ❌ NO (used by cli)     |
| @codebuff/bigquery      | Library     | Analytics               | ❌ NO (used by web)     |
| @codebuff/evals         | Library     | Testing/evals           | ❌ NO (dev/test only)   |
| @codebuff/.agents       | Config      | Agent definitions       | ❌ NO (data files)      |
| @codebuff/agents        | Library     | Agent implementations   | ❌ NO (used by runtime) |

### Dependency Flow

```
@codebuff/web (DEPLOY THIS)
  ├─> @codebuff/internal (database, DB migrations)
  ├─> @codebuff/billing
  ├─> @codebuff/agent-runtime
  │     └─> @codebuff/agents
  ├─> @codebuff/bigquery
  └─> @codebuff/common

@codebuff/cli (LOCAL ONLY)
  ├─> @codebuff/sdk
  ├─> @codebuff/agent-runtime
  └─> @codebuff/code-map
```

All internal packages are **bundled into the web deployment** via the monorepo workspace setup.

## Solution Strategy

### ✅ COMPLETED: Fix Web Service

**Status:** DEPLOYING with correct build command

**Changes Made:**

```json
{
  "buildCommand": "bun install && bun --cwd web run build"
}
```

This correctly:

1. Installs all workspace dependencies
2. Builds the Next.js application
3. Bundles all internal packages automatically

### 🎯 RECOMMENDED: Clean Up Unnecessary Services

The 11 failed services should be **removed from Railway** because:

1. They're not meant to be deployed
2. They don't have server processes
3. They're already included in the web bundle
4. They waste Railway resources and credits

#### Option A: Delete via Railway Dashboard (Easiest)

1. Go to: https://railway.com/project/bfdf5d68-2243-4458-b922-a075645621e4
2. For each failed service (except web):
   - Click on the service
   - Go to Settings
   - Scroll to "Danger Zone"
   - Click "Delete Service"
3. Keep only `@codebuff/web`

**Services to DELETE:**

- @codebuff/build-tools
- @codebuff/agent-runtime
- @codebuff/code-map
- @codebuff/.agents
- @codebuff/cli
- @codebuff/billing
- @codebuff/evals
- @codebuff/bigquery
- @codebuff/sdk
- @codebuff/agents
- @codebuff/internal

#### Option B: Delete via Railway CLI

```bash
# Delete each service
railway service delete @codebuff/build-tools
railway service delete @codebuff/agent-runtime
railway service delete @codebuff/code-map
railway service delete @codebuff/.agents
railway service delete @codebuff/cli
railway service delete @codebuff/billing
railway service delete @codebuff/evals
railway service delete @codebuff/bigquery
railway service delete @codebuff/sdk
railway service delete @codebuff/agents
railway service delete @codebuff/internal
```

### Alternative: Keep Services But Make Them Inactive

If you want to keep the service entries for reference but not deploy them:

1. Go to each service in Railway Dashboard
2. Settings → "Pause Service" or disable deployments
3. This keeps the service definition without attempting deployments

## Why This Approach Is Correct

### 1. Monorepo Best Practices

In a monorepo architecture:

- **Only "apps" are deployed** (web, api servers, etc.)
- **Libraries/packages are dependencies** (bundled with apps)
- Railway should have **1 service per deployable app**

### 2. Cost Efficiency

- Each Railway service has costs (even failed ones use resources)
- Unnecessary services clutter the dashboard
- Build attempts for failed services waste compute credits

### 3. Maintenance

- Simpler to manage 1 service vs 12
- Clear deployment pipeline
- Easier debugging and monitoring

## Final Architecture

### What Railway Should Look Like

```
codebuff-local Project
├── @codebuff/web (Service) ✅ ACTIVE
└── postgres (Database) ✅ ACTIVE
```

That's it! Just 2 resources:

1. **Web Service** - Runs the Next.js app
2. **PostgreSQL Database** - Stores data

All the packages (@codebuff/internal, @codebuff/billing, etc.) are **built into the web bundle** during the build process.

## Verification Steps

### After Web Deployment Succeeds

1. **Check Health Endpoint:**

   ```bash
   curl https://codebuffweb-production.up.railway.app/api/health
   ```

   Expected: HTTP 200 response

2. **Verify App Works:**
   - Open https://codebuffweb-production.up.railway.app
   - Test authentication
   - Verify all features work

3. **Confirm All Dependencies Work:**
   - Database connection (internal package)
   - Billing features (billing package)
   - Agent runtime (agent-runtime package)

   All should work because they're bundled in the web deployment!

### After Deleting Other Services

1. **Verify Clean Dashboard:**

   ```bash
   railway service status --all
   ```

   Should only show:
   - @codebuff/web | ACTIVE
   - postgres | ACTIVE (if you added database)

2. **Confirm Web Still Works:**
   - App should function exactly the same
   - No difference in functionality
   - All internal packages still work (they're bundled)

## Common Questions

### Q: Won't deleting @codebuff/internal break the database?

**A:** No! The `@codebuff/internal` package is bundled into the web deployment. The web service runs migrations via the start command:

```json
"startCommand": "bun --cwd packages/internal run db:migrate && bun --cwd web run start"
```

### Q: What about @codebuff/cli?

**A:** The CLI is meant to run **locally on developer machines**, not deployed to Railway. Users install it via npm/bun.

### Q: Won't I lose the SDK if I delete @codebuff/sdk?

**A:** The SDK is an **npm package** published to npm registry, not a deployed service. Deleting the Railway service doesn't affect the npm package.

### Q: Can I deploy multiple services later if needed?

**A:** Yes! If you later need separate services (e.g., a dedicated API server, background workers, etc.), you can add them. But currently, only web needs deployment.

## Execution Plan

### Step 1: Wait for Web to Deploy ⏳

**Status:** In progress (5-10 minutes)

- Monitor: `railway service status -s @codebuff/web`
- Check logs: `railway logs --service @codebuff/web`

### Step 2: Verify Web Works ✅

Once web status shows ACTIVE:

```bash
# Check health
curl https://codebuffweb-production.up.railway.app/api/health

# Visit in browser
open https://codebuffweb-production.up.railway.app
```

### Step 3: Clean Up Other Services 🗑️

Choose one method:

**Method 1: Railway Dashboard (Recommended)**

- Quickest and safest
- Visual confirmation
- Can review before deleting

**Method 2: Railway CLI**

```bash
# Delete all non-web services
for service in "build-tools" "agent-runtime" "code-map" ".agents" "cli" "billing" "evals" "bigquery" "sdk" "agents" "internal"; do
  railway service delete @codebuff/$service
done
```

### Step 4: Update Documentation 📝

- Update project README with single-service architecture
- Document that only web service is deployed
- Remove references to deploying other services

## Timeline

- ✅ **T+0:** Web deployment started (using fixed build command)
- ⏳ **T+5-10 min:** Web deployment completes
- 🎯 **T+15 min:** Verify web works, delete other services
- ✅ **T+20 min:** Clean Railway dashboard with only web service

## Success Criteria

- [ ] Web service status: ACTIVE
- [ ] Health endpoint returns 200
- [ ] Application accessible and functional
- [ ] Only 1-2 services in Railway (web + optional database)
- [ ] No failed services cluttering dashboard
- [ ] All app features work (proving internal packages are bundled correctly)

## Links

- **Railway Dashboard:** https://railway.com/project/bfdf5d68-2243-4458-b922-a075645621e4
- **Web App:** https://codebuffweb-production.up.railway.app
- **Build Logs:** Check dashboard for latest deployment

---

**Next Action:** Wait for web deployment to complete, then clean up unnecessary services.
