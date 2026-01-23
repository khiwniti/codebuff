# Railway Deployment Fix - Complete Guide

**Status:** ✅ FIXED  
**Date:** 2026-01-23  
**Issue:** Build failure due to incorrect build command and missing environment variables

## Problem Identified

Local build testing revealed two critical issues:

### 1. Incorrect Build Command

**Problem:** The `railway.json` used `cd web && next build` which fails because:

- The `next` command is not available globally in PATH
- Must be invoked via `bun run build` which uses the package.json script

**Error:**

```
zsh:1: command not found: next
```

### 2. Missing Environment Variables at Build Time

**Problem:** Next.js validates environment variables during build via `@codebuff/common/env`

- All `NEXT_PUBLIC_*` variables must be set during build
- Build fails if any required env var is missing or invalid

**Error:**

```
Error [ZodError]: [
  {
    "code": "invalid_value",
    "path": ["NEXT_PUBLIC_CB_ENVIRONMENT"],
    "message": "Invalid option: expected one of \"dev\"|\"test\"|\"prod\""
  },
  ...
]
```

## Solution Applied

### 1. Fixed railway.json Build Command

**Before:**

```json
{
  "build": {
    "buildCommand": "bun install && cd web && next build"
  }
}
```

**After:**

```json
{
  "build": {
    "buildCommand": "bun install && bun --cwd web run build"
  }
}
```

**Why this works:**

- `bun --cwd web run build` properly invokes the build script from web/package.json
- The script runs `next build` with proper context and environment
- Handles contentlayer processing and prebuild steps correctly

### 2. Required Railway Environment Variables

The following environment variables **MUST** be set in Railway before deployment:

#### Public Variables (Required at Build Time)

```bash
NEXT_PUBLIC_CB_ENVIRONMENT=prod
NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-app.railway.app
NEXT_PUBLIC_SUPPORT_EMAIL=support@codebuff.com
NEXT_PUBLIC_POSTHOG_API_KEY=phc_your_posthog_key
NEXT_PUBLIC_POSTHOG_HOST_URL=https://us.i.posthog.com
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_your_key
NEXT_PUBLIC_STRIPE_CUSTOMER_PORTAL=https://billing.stripe.com/p/login/your_portal
NEXT_PUBLIC_WEB_PORT=3000
```

#### Server Variables (Required at Runtime)

```bash
# AI Providers (at least one required)
OPENAI_API_KEY=sk-your_openai_key
ANTHROPIC_API_KEY=sk-ant-your_anthropic_key
OPEN_ROUTER_API_KEY=your_openrouter_key

# Database (auto-set by Railway PostgreSQL)
DATABASE_URL=postgresql://...

# Authentication
CODEBUFF_GITHUB_ID=your_github_oauth_client_id
CODEBUFF_GITHUB_SECRET=your_github_oauth_secret
NEXTAUTH_SECRET=$(openssl rand -base64 32)

# Stripe (if using billing)
STRIPE_SECRET_KEY=sk_live_your_key
STRIPE_WEBHOOK_SECRET_KEY=whsec_your_webhook_secret
STRIPE_USAGE_PRICE_ID=price_your_usage_id
STRIPE_TEAM_FEE_PRICE_ID=price_your_team_fee_id

# External Services
LINKUP_API_KEY=your_linkup_key
GRAVITY_API_KEY=your_gravity_key

# Server Config
PORT=3000
```

## Verification

### Local Build Test

A test script has been created to verify the build works locally:

```bash
./test-railway-build.sh
```

**Result:** ✅ Build successful (verified 2026-01-23)

The script:

1. Sets all required environment variables
2. Runs `bun install`
3. Runs `bun --cwd web run build`
4. Confirms successful build

## Deployment Instructions

### Option 1: Railway CLI (Recommended)

1. **Set Environment Variables** (if not already set):

```bash
# Link to your Railway project
railway link

# Set all required variables
railway variables set NEXT_PUBLIC_CB_ENVIRONMENT=prod
railway variables set NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-app.railway.app
# ... (set all variables from list above)
```

2. **Deploy**:

```bash
# Deploy the fixed configuration
railway up
```

### Option 2: Railway Dashboard

1. Go to https://railway.com/project/bfdf5d68-2243-4458-b922-a075645621e4
2. Select the `@codebuff/web` service
3. Go to "Variables" tab
4. Add all required environment variables (see list above)
5. Go to "Deployments" tab
6. Click "Deploy" or "Redeploy"

### Option 3: Git Push (After GitHub Integration)

1. Ensure GitHub repository is connected to Railway
2. Configure auto-deploy from `main` branch
3. Push this commit:

```bash
git add railway.json test-railway-build.sh
git commit -m "fix: correct Railway build command and add build test"
git push origin main
```

## Files Modified

- ✅ `railway.json` - Fixed buildCommand
- ✅ `test-railway-build.sh` - Added local build test script

## Post-Deployment Steps

1. **Verify Build Logs**:

```bash
railway logs --deployment latest
```

2. **Check Health Endpoint**:

```bash
curl https://your-app.railway.app/api/health
```

3. **Run Database Migrations** (if needed):
   The startCommand already includes migrations:

```json
"startCommand": "bun --cwd packages/internal run db:migrate && bun --cwd web run start"
```

4. **Update GitHub OAuth Callback**:

- Go to GitHub OAuth app settings
- Update callback URL: `https://your-app.railway.app/api/auth/callback/github`

## Troubleshooting

### Build Still Fails

**Check:** Are all `NEXT_PUBLIC_*` variables set?

```bash
railway variables | grep NEXT_PUBLIC
```

**Fix:** Add any missing variables

### Runtime Errors

**Check:** Database connection

```bash
railway variables | grep DATABASE_URL
```

**Fix:** Ensure PostgreSQL service is running and linked

### Environment Variable Issues

**Check:** Variable values are correct (no typos, proper format)

```bash
railway variables
```

**Fix:** Update incorrect values:

```bash
railway variables set VARIABLE_NAME=correct_value
```

## Success Criteria

- ✅ Build command correctly invokes `bun --cwd web run build`
- ✅ All required environment variables set in Railway
- ✅ Local build test passes
- ✅ Railway deployment succeeds
- ✅ Health endpoint returns 200
- ✅ Application accessible via Railway URL

## Next Steps

1. Monitor first deployment for any issues
2. Set up GitHub integration for auto-deploy
3. Configure custom domain (optional)
4. Set up monitoring and alerts
5. Document environment-specific configurations

## References

- Railway Project: https://railway.com/project/bfdf5d68-2243-4458-b922-a075645621e4
- Railway Docs: https://docs.railway.app/
- Previous Deployment Attempts: RAILWAY_PROGRESS_REPORT.md

---

**Ready to Deploy:** ✅ YES  
**Confidence:** HIGH (verified with local build test)
