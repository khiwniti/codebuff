# Railway Health Check Failure - Debugging Log

**Date:** 2026-01-23  
**Issue:** Health check failing - service not starting

## Attempts Made

### Attempt 1: Original Configuration ❌

```json
"startCommand": "bun --cwd packages/internal run db:migrate && bun --cwd web run start"
```

**Result:** FAILED - Health check timeout
**Hypothesis:** Database migration failing or blocking startup

### Attempt 2: Remove Migration ❌

```json
"startCommand": "bun --cwd web run start"
```

**Result:** FAILED - Health check timeout  
**Hypothesis:** Not a migration issue, web server not starting

### Attempt 3: Direct Next.js Start (Current) ⏳

```json
"startCommand": "cd web && next start -p ${PORT:-3000}"
```

**Status:** DEPLOYING (Deployment: 60aeb03c-1723-4f19-996a-61555df09235)
**Hypothesis:** Bun might not be correctly running Next.js start script

## Environment Variables Status

✅ All NEXT*PUBLIC*\* variables set
✅ All API keys set (dummy values for now)
✅ DATABASE_URL set
✅ AUTH variables set
✅ DISCORD variables set  
✅ NEXTAUTH_URL added
✅ PORT set to 3000

## Possible Root Causes

### 1. Runtime Environment Issue

- Bun might not be properly executing `next start`
- Node modules might not be in correct location
- Next.js build artifacts might be missing

### 2. Port Binding Issue

- Railway expects service to bind to `$PORT`
- Next.js might not be reading PORT correctly
- Health check hitting wrong port

### 3. Missing Runtime Dependencies

- Next.js standalone mode not enabled
- Build artifacts not in correct location after COPY
- Node modules cache issue

### 4. Environment Validation Failing

- Server-side env validation failing at runtime
- Missing required env vars we haven't identified
- Env validation blocking startup

## Next Steps to Try

### If Current Attempt Fails:

#### Option A: Use Node Instead of Bun

```json
"startCommand": "cd web && node_modules/.bin/next start -p ${PORT:-3000}"
```

#### Option B: Enable Standalone Mode

Add to `next.config.mjs`:

```js
output: 'standalone'
```

#### Option C: Custom Start Script

Create `web/server.js`:

```js
import { createServer } from 'http'
import next from 'next'

const port = process.env.PORT || 3000
const app = next({ dev: false })
const handle = app.getRequestHandler()

app.prepare().then(() => {
  createServer((req, res) => {
    handle(req, res)
  }).listen(port, () => {
    console.log(`> Ready on http://localhost:${port}`)
  })
})
```

Then use:

```json
"startCommand": "cd web && node server.js"
```

#### Option D: Debug Container Locally

```bash
# Pull the built image
docker pull production-asia-southeast1-eqsg3a.railway-registry.com/37d80c61-bcc9-438e-8bac-c5b541395bc0:e15dee95-4934-4879-b09a-414da7d3bef0

# Run it locally to see errors
docker run -it -e PORT=3000 [image] /bin/bash
cd web
next start
```

#### Option E: Simplify to Basic HTTP Server

Test if it's a Next.js issue by creating minimal server:

```js
// web/test-server.js
require('http')
  .createServer((req, res) => {
    if (req.url === '/api/health') {
      res.writeHead(200)
      res.end('OK')
    } else {
      res.writeHead(200)
      res.end('Hello')
    }
  })
  .listen(process.env.PORT || 3000, () => {
    console.log('Server running')
  })
```

## Monitoring Current Deployment

```bash
# Check status
railway service status -s @codebuff/web

# View logs
railway logs --service @codebuff/web | tail -100

# Check health endpoint manually
curl -v https://codebuffweb-production.up.railway.app/api/health
```

## Build vs Runtime

**Build Phase:** ✅ SUCCESS (141 seconds)

- Dependencies installed
- Next.js compiled
- No build errors

**Runtime Phase:** ❌ FAILURE

- Service not responding
- Health check timing out
- No logs showing server startup

This suggests the issue is specifically with **starting** the Next.js server, not building it.

---

**Current Deployment:** 60aeb03c-1723-4f19-996a-61555df09235  
**Status:** QUEUED → BUILDING → Testing...  
**Waiting for:** Health check result
