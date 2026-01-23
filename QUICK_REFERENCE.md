# 📝 Codebuff Quick Reference

## 🚀 Railway Deployment - Quick Steps

```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login
railway login

# 3. Run setup script
./setup-railway.sh

# 4. Set environment variables
./setup-railway-env.sh
# OR manually: railway variables set KEY=value

# 5. Deploy
railway up

# 6. Run migrations
railway run bun run db:migrate
```

## 🔑 Required Environment Variables

| Variable | Description | How to Get |
|----------|-------------|-----------|
| `CODEBUFF_GITHUB_ID` | GitHub OAuth Client ID | See GITHUB_OAUTH_SETUP.md |
| `CODEBUFF_GITHUB_SECRET` | GitHub OAuth Client Secret | See GITHUB_OAUTH_SETUP.md |
| `NEXTAUTH_SECRET` | NextAuth secret (32+ chars) | `openssl rand -base64 32` |
| `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` | AI provider API key | platform.openai.com or console.anthropic.com |
| `NEXT_PUBLIC_CODEBUFF_APP_URL` | Your app URL | From Railway deployment |
| `DATABASE_URL` | PostgreSQL connection string | Auto-set by Railway |

## 📁 Important Files

| File | Purpose |
|------|---------|
| `SETUP_COMPLETE.md` | Overview and getting started |
| `RAILWAY_DEPLOYMENT_GUIDE.md` | Complete Railway deployment guide |
| `GITHUB_OAUTH_SETUP.md` | GitHub OAuth configuration |
| `setup-railway.sh` | Automated Railway setup |
| `setup-railway-env.sh` | Interactive env vars setup |
| `.env.railway.template` | All available env vars |
| `railway.json` | Railway deployment config |
| `nixpacks.toml` | Build configuration |

## 🛠️ Common Commands

### Local Development
```bash
bun run dev              # Start all services
bun run start-web        # Web server only
bun run start-cli        # CLI only
bun run db:migrate       # Run migrations
bun run db:studio        # Open database UI
```

### Railway
```bash
railway login            # Login
railway init             # New project
railway link             # Link existing
railway add postgres     # Add database
railway variables        # View env vars
railway up               # Deploy
railway logs             # View logs
railway logs -f          # Follow logs
railway open             # Open dashboard
railway shell            # Open shell
railway connect postgres # Connect to DB
railway run <command>    # Run command
```

### Environment Setup
```bash
# Generate NextAuth secret
openssl rand -base64 32

# Set single variable
railway variables set KEY=value

# View all variables
railway variables
```

## 📦 Project Structure

```
codebuff/
├── web/                    # Next.js web app
├── cli/                    # CLI application
├── sdk/                    # TypeScript SDK
├── common/                 # Shared code & DB
├── agents/                 # Agent definitions
├── packages/               # Internal packages
├── python-app/             # Python CLI (experimental)
├── .env.local              # Local config (DO NOT COMMIT)
├── railway.json            # Railway config
└── nixpacks.toml           # Build config
```

## 🔗 Quick Links

- **Codebuff**: https://codebuff.com
- **Docs**: https://codebuff.com/docs
- **Discord**: https://codebuff.com/discord
- **GitHub**: https://github.com/CodebuffAI/codebuff
- **Railway**: https://railway.app
- **Railway Docs**: https://docs.railway.app

## 💡 Tips

1. **Separate OAuth apps**: Use different GitHub OAuth apps for dev/prod
2. **Environment variables**: Never commit `.env.local` to git
3. **Logs**: Use `railway logs -f` to debug deployment issues
4. **Database**: Railway PostgreSQL is automatically configured
5. **Credits**: After first login, manually add credits via database
6. **Testing**: Test OAuth flow locally before deploying

## 🐛 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| OAuth redirect error | Check callback URL matches exactly |
| Database connection failed | Verify `DATABASE_URL` is set |
| Build timeout | Increase timeout in Railway settings |
| Bun not found | Check `nixpacks.toml` includes bun |
| Missing env vars | Run `railway variables` to verify |

## 📚 Learn More

- **First time?** → Read `SETUP_COMPLETE.md`
- **OAuth setup?** → Read `GITHUB_OAUTH_SETUP.md`
- **Deploying?** → Read `RAILWAY_DEPLOYMENT_GUIDE.md`
- **Contributing?** → Read `CONTRIBUTING.md`

## ⚡ Ultra-Quick Deploy (TL;DR)

```bash
# Prerequisites: Railway account, GitHub OAuth app, AI API key

npm i -g @railway/cli && railway login
./setup-railway.sh
./setup-railway-env.sh
railway up
railway run bun run db:migrate

# Done! 🎉
```

---

**Everything else**: See the detailed guides in the repository.
