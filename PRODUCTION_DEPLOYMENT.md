# Production Deployment Guide

This document covers the steps needed to deploy codebuff for production.

## 1. Vercel Environment Variables

The Vercel build is failing because required environment variables are not set. To fix this:

### Required Environment Variables for Production Build

Go to Vercel Dashboard → Your Project → Settings → Environment Variables and add:

```
NEXT_PUBLIC_CB_ENVIRONMENT=prod
NEXT_PUBLIC_CODEBUFF_APP_URL=https://codebuff.com
NEXT_PUBLIC_SUPPORT_EMAIL=support@codebuff.com
NEXT_PUBLIC_POSTHOG_API_KEY=your_posthog_api_key
NEXT_PUBLIC_POSTHOG_HOST_URL=https://us.i.posthog.com
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_xxx
NEXT_PUBLIC_STRIPE_CUSTOMER_PORTAL=https://billing.stripe.com/p/login/test
NEXT_PUBLIC_WEB_PORT=3000
```

### Server-side Environment Variables (not in NEXT_PUBLIC_)

```
OPEN_ROUTER_API_KEY=xxx
OPENAI_API_KEY=xxx
ANTHROPIC_API_KEY=xxx
FIREWORKS_API_KEY=xxx
DATABASE_URL=postgres://xxx
CODEBUFF_GITHUB_ID=xxx
CODEBUFF_GITHUB_SECRET=xxx
NEXTAUTH_SECRET=xxx
STRIPE_SECRET_KEY=xxx
STRIPE_WEBHOOK_SECRET_KEY=xxx
```

### NVIDIA NIM Configuration

```
CODEBUFF_CUSTOM_MODEL_BASE_URL=https://integrate.api.nvidia.com/v1
CODEBUFF_CUSTOM_MODEL_API_KEY=your_nvidia_nim_api_key
```

## 2. Vercel Build Settings

In Vercel Dashboard → Your Project → Settings → General:

- **Build Command**: `bun install && bun run build`
- **Install Command**: `bun install`
- **Output Directory**: `web/.next` (or leave as default)

Make sure the root directory is set to `/` (not `/web`).

## 3. Re-trigger Build

After setting environment variables, go to Deployments and click "Redeploy" on the latest deployment.

## 4. Publishing openbuff to npm

To publish the openbuff package to npm:

```bash
cd openbuff/release

# Option 1: Using environment variable
NPM_TOKEN=your_npm_token npm publish --access public

# Option 2: Using the publish script
NPM_TOKEN=your_npm_token node publish.js

# Option 3: Using npm config
npm config set //registry.npmjs.org/:_authToken=your_npm_token
npm publish --access public
```

## 5. Verify Build

After fixing environment variables, the build should complete successfully:

```
✓ Compiled successfully
Environment validation passed
BUILD COMPLETED
```

## Troubleshooting

### Build still fails after setting env vars

1. Check that all `NEXT_PUBLIC_*` variables are set
2. Make sure `NEXT_PUBLIC_CB_ENVIRONMENT=prod` (not "production")
3. Check Vercel deployment logs for specific error messages

### Environment validation errors

The error shows missing or invalid values. Common issues:
- `NEXT_PUBLIC_STRIPE_CUSTOMER_PORTAL` must be a valid URL
- `NEXT_PUBLIC_WEB_PORT` must be a number ≥ 1000

### npm publish fails

1. Verify your npm token has publish permissions
2. Check that the version doesn't already exist
3. Ensure you're logged in: `npm login`