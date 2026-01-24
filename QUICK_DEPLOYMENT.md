# 🚀 Codebuff Deployment Quick Reference

## 📋 One-Click Railway Deployment

```bash
# Complete automated setup
make deploy-setup

# Manual deployment
make deploy
```

## 🔧 Essential Commands

### Development

```bash
make setup      # First-time setup
make dev        # Start all services
make cli        # Start CLI only
make web        # Start web server only
```

### Deployment

```bash
make deploy     # Deploy to Railway
make deploy-logs # View logs
make down       # Stop services
```

### CLI Configuration

```bash
make cli-cloud  # Configure CLI for cloud usage
```

## 🌐 Domain Setup

### Railway Custom Domain

1. `railway open` → Settings → Domains
2. Add domain: `codebuff.yourdomain.com`
3. DNS: `CNAME → cname.railway.app`
4. Update: `NEXT_PUBLIC_CODEBUFF_APP_URL=https://yourdomain.com`
5. `make deploy`

### CLI Connection

```bash
# Local .env.local
NEXT_PUBLIC_CB_ENVIRONMENT=prod
NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-railway-url.railway.app
OPENAI_API_KEY=your_key_here

# Start CLI connected to cloud
make cli
```

## 🔑 Required Environment Variables

### Railway (Production)

```bash
# Authentication
NEXTAUTH_SECRET=openssl_rand_base64_32
CODEBUFF_GITHUB_ID=github_oauth_client_id
CODEBUFF_GITHUB_SECRET=github_oauth_client_secret

# AI Provider (at least one)
OPENAI_API_KEY=sk-proj-...
ANTHROPIC_API_KEY=sk-ant-...
OPEN_ROUTER_API_KEY=sk-or-v1-...

# Public URL
NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-app.railway.app
```

### Local CLI (to connect to cloud)

```bash
NEXT_PUBLIC_CB_ENVIRONMENT=prod
NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-railway-url.railway.app
OPENAI_API_KEY=your_key_here
```

## ⚡ Quick Workflow

### New Project Setup

```bash
git clone your-repo
cd codebuff
make setup
make deploy-setup
```

### Daily Development

```bash
make dev          # Local development
make cli          # CLI with local backend
make deploy       # Deploy changes
```

### Production CLI Usage

```bash
# Configure for cloud
make cli-cloud

# Use cloud backend
make cli
```

## 🛠️ Troubleshooting

### CLI Connection Issues

```bash
# Check backend connectivity
curl https://your-app.railway.app/api/healthz

# Verify environment
cat .env.local | grep NEXT_PUBLIC_CODEBUFF_APP_URL
```

### Deployment Issues

```bash
# View logs
make deploy-logs

# Check status
make deploy-status

# List variables
make deploy-vars
```

### Database Issues

```bash
# Run migrations
railway run bun run db:migrate

# Access database
make studio          # Local
railway shell        # Production
```

## 📚 Documentation

- **Full Guide**: [CLI_DEPLOYMENT_GUIDE.md](./CLI_DEPLOYMENT_GUIDE.md)
- **Checklist**: [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)
- **Contributing**: [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Railway Docs**: https://docs.railway.app
- **Community**: https://codebuff.com/discord

## 🆘 Help Commands

```bash
make help                    # All commands
./deploy-railway-complete.sh # Interactive setup
railway help                 # Railway CLI help
```

---

💡 **Pro Tip**: Use `make setup` for new environments and `make dev` for daily development!
