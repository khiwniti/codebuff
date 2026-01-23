# Railway Build Fix - Resolved! ✅

## Problem

Railway build was failing with error:
```
error: Script not found "db:migrate"
```

## Root Cause

The build command in `railway.json` and `nixpacks.toml` was trying to run:
```bash
bun run db:migrate
```

However, `db:migrate` script doesn't exist in the root `package.json`. It exists in `packages/internal/package.json`.

## Solution

Updated build commands to use the correct workspace paths:

### Before (Broken)
```json
// railway.json
{
  "build": {
    "buildCommand": "bun install && bun run db:migrate && bun run build:web"
  },
  "deploy": {
    "startCommand": "cd web && bun run start"
  }
}
```

### After (Fixed) ✅
```json
// railway.json
{
  "build": {
    "buildCommand": "bun install && bun --cwd packages/internal run db:migrate && bun --cwd web run build"
  },
  "deploy": {
    "startCommand": "bun --cwd web run start"
  }
}
```

## Correct Commands

### Database Migration
```bash
# Local
bun --cwd packages/internal run db:migrate

# Railway
railway run bun --cwd packages/internal run db:migrate
```

### Build Web
```bash
# Local
bun --cwd web run build

# Railway (in build phase)
bun --cwd web run build
```

### Start Web Server
```bash
# Local
bun --cwd web run start

# Railway
bun --cwd web run start
```

## Updated Files

1. **railway.json** - Fixed build and deploy commands
2. **nixpacks.toml** - Fixed build phase commands
3. **RAILWAY_DEPLOYMENT_GUIDE.md** - Updated documentation

## Testing Locally

To test the build process locally:

```bash
cd /workspace/codebuff

# 1. Install dependencies
bun install

# 2. Run migrations (requires DATABASE_URL)
bun --cwd packages/internal run db:migrate

# 3. Build web
bun --cwd web run build

# 4. Start web server
bun --cwd web run start
```

## Railway Deployment

Now when you deploy to Railway:

1. **Build phase** will run:
   - `bun install` - Install all dependencies
   - `bun --cwd packages/internal run db:migrate` - Run database migrations
   - `bun --cwd web run build` - Build Next.js app

2. **Deploy phase** will run:
   - `bun --cwd web run start` - Start the production server

## Workspace Structure

Codebuff uses Bun workspaces:

```
codebuff/
├── package.json (root - no db:migrate script)
├── packages/
│   └── internal/
│       └── package.json (has db:migrate script) ✅
├── web/
│   └── package.json (has build and start scripts) ✅
├── cli/
│   └── package.json
└── sdk/
    └── package.json
```

## Key Takeaways

1. **Use `--cwd` flag** to run scripts in workspace packages
2. **Check package.json** in each workspace for available scripts
3. **Root package.json** doesn't have all scripts from workspaces

## Verification

After this fix, Railway build should succeed! You can verify by:

1. Pushing to GitHub (done ✅)
2. Railway will auto-deploy
3. Check build logs for success

## Next Steps

If Railway is still not working, check:

1. **Environment variables** are set in Railway
2. **DATABASE_URL** is configured (auto-set when you add PostgreSQL)
3. **GitHub OAuth** credentials are set
4. **AI API keys** are configured

See `RAILWAY_DEPLOYMENT_GUIDE.md` for complete deployment instructions.

---

**Fixed and pushed!** ✅

Repository: https://github.com/khiwniti/codebuff-local
