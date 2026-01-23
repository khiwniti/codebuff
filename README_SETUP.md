# 🎉 Codebuff Configuration Complete!

Your Codebuff repository has been successfully configured for Railway deployment!

## ✅ What Was Done

### 1. Repository Setup
- ✅ Cloned from https://github.com/CodebuffAI/codebuff.git
- ✅ Installed Bun v1.3.6 package manager
- ✅ Installed all project dependencies (1755 packages)
- ✅ Created `.env.local` for local development

### 2. Railway Configuration
- ✅ Created `railway.json` - Railway deployment configuration
- ✅ Created `nixpacks.toml` - Build environment setup
- ✅ Created `.env.railway.template` - Environment variables reference

### 3. Documentation Created
- ✅ `RAILWAY_DEPLOYMENT_GUIDE.md` - Complete Railway deployment guide (11 KB)
- ✅ `GITHUB_OAUTH_SETUP.md` - GitHub OAuth setup instructions (8.4 KB)
- ✅ `SETUP_COMPLETE.md` - Setup summary and next steps (6.4 KB)
- ✅ `QUICK_REFERENCE.md` - Quick reference card (4.6 KB)

### 4. Automation Scripts
- ✅ `setup-railway.sh` - Interactive Railway setup (executable)
- ✅ `setup-railway-env.sh` - Environment variables setup (executable)

## 🚀 Next Steps (Choose Your Path)

### Path A: Quick Deploy to Railway (Recommended)

```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Run setup script
./setup-railway.sh

# 3. Configure environment variables
./setup-railway-env.sh

# 4. Deploy!
railway up
```

**Need help?** See `RAILWAY_DEPLOYMENT_GUIDE.md`

### Path B: Local Development First

```bash
# 1. Set up GitHub OAuth (see GITHUB_OAUTH_SETUP.md)

# 2. Update .env.local with:
#    - CODEBUFF_GITHUB_ID
#    - CODEBUFF_GITHUB_SECRET  
#    - OPENAI_API_KEY or ANTHROPIC_API_KEY
#    - NEXTAUTH_SECRET (generate with: openssl rand -base64 32)

# 3. Start PostgreSQL (if Docker works in your environment)
cd packages/internal/src/db && docker-compose up -d

# 4. Run migrations
bun run db:migrate

# 5. Start development server
bun run dev
```

**Note**: Docker may have limitations in containerized environments. Consider using Railway PostgreSQL.

## 📚 Documentation Overview

| File | Description | When to Use |
|------|-------------|-------------|
| **SETUP_COMPLETE.md** | Overview & getting started | 👉 **Start here!** |
| **QUICK_REFERENCE.md** | Quick commands & links | Quick lookup |
| **RAILWAY_DEPLOYMENT_GUIDE.md** | Complete Railway guide | Deploying to production |
| **GITHUB_OAUTH_SETUP.md** | OAuth configuration | Setting up authentication |
| **CONTRIBUTING.md** | Development guidelines | Contributing to project |
| **.env.railway.template** | All environment variables | Environment setup |

## 🔑 Configuration Requirements

Before deploying, you need to set up:

### Required:
1. **GitHub OAuth App** (see `GITHUB_OAUTH_SETUP.md`)
   - `CODEBUFF_GITHUB_ID`
   - `CODEBUFF_GITHUB_SECRET`

2. **AI API Key** (at least one)
   - `OPENAI_API_KEY` from https://platform.openai.com/api-keys
   - OR `ANTHROPIC_API_KEY` from https://console.anthropic.com/

3. **NextAuth Secret**
   - Generate: `openssl rand -base64 32`
   - Set as: `NEXTAUTH_SECRET`

4. **Database**
   - Railway: Automatically configured when you add PostgreSQL
   - Local: Use Docker Compose or external PostgreSQL

### Optional:
- Stripe (for billing)
- External services (Linkup, Loops, PostHog)
- Discord integration

## 🎯 Quick Start Commands

```bash
# Generate NextAuth secret
openssl rand -base64 32

# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Add PostgreSQL
railway add postgres

# Set environment variable
railway variables set KEY=value

# Deploy
railway up

# View logs
railway logs -f

# Run migrations
railway run bun run db:migrate
```

## 📁 Project Structure

```
codebuff/
├── 📄 RAILWAY_DEPLOYMENT_GUIDE.md   ← Railway deployment
├── 📄 GITHUB_OAUTH_SETUP.md         ← OAuth setup
├── 📄 SETUP_COMPLETE.md             ← Overview
├── 📄 QUICK_REFERENCE.md            ← Quick reference
├── ⚙️ railway.json                   ← Railway config
├── ⚙️ nixpacks.toml                  ← Build config
├── 🔧 setup-railway.sh               ← Setup script
├── 🔧 setup-railway-env.sh           ← Env setup script
├── 🔒 .env.local                     ← Local config (DO NOT COMMIT)
├── 📝 .env.railway.template          ← Railway env template
├── web/                              ← Next.js app
├── cli/                              ← CLI app
├── sdk/                              ← TypeScript SDK
├── common/                           ← Shared code & DB
├── agents/                           ← Agent definitions
└── packages/                         ← Internal packages
```

## ⚡ TL;DR - Ultra Quick Deploy

```bash
# 1. Get your credentials ready:
#    - GitHub OAuth app (client ID & secret)
#    - OpenAI or Anthropic API key

# 2. Deploy in 4 commands:
npm i -g @railway/cli && railway login
./setup-railway.sh
./setup-railway-env.sh
railway up && railway run bun run db:migrate

# 3. Done! 🎉
```

## 🔗 Important Links

- **Railway Dashboard**: https://railway.app
- **Codebuff Website**: https://codebuff.com
- **Codebuff Docs**: https://codebuff.com/docs
- **Codebuff Discord**: https://codebuff.com/discord
- **GitHub Repo**: https://github.com/CodebuffAI/codebuff
- **Railway Docs**: https://docs.railway.app
- **GitHub OAuth Apps**: https://github.com/settings/developers

## 💡 Pro Tips

1. **Create separate OAuth apps** for development and production
2. **Never commit** `.env.local` or secrets to git
3. **Use Railway dashboard** for easy environment variable management
4. **Follow logs** during first deployment: `railway logs -f`
5. **Test locally first** if possible, to catch configuration issues early

## 🐛 Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| OAuth redirect error | Verify callback URL: `https://your-app.railway.app/api/auth/callback/github` |
| Database connection error | Ensure PostgreSQL is added: `railway add postgres` |
| Build fails | Check logs: `railway logs` and verify `nixpacks.toml` |
| Missing env vars | Run: `railway variables` to list all variables |
| App won't start | Verify all required env vars are set |

For more troubleshooting, see `RAILWAY_DEPLOYMENT_GUIDE.md`

## 📖 Recommended Reading Order

1. **SETUP_COMPLETE.md** - Start here for overview
2. **GITHUB_OAUTH_SETUP.md** - Set up authentication
3. **RAILWAY_DEPLOYMENT_GUIDE.md** - Deploy to production
4. **QUICK_REFERENCE.md** - Bookmark for quick lookup

## 🎓 Learning Resources

- First time with Railway? → https://docs.railway.app/getting-started
- First time with Next.js? → https://nextjs.org/learn
- First time with Bun? → https://bun.sh/docs

## 🤝 Need Help?

- **Discord**: https://codebuff.com/discord (Community support)
- **GitHub Issues**: https://github.com/CodebuffAI/codebuff/issues
- **Railway Discord**: https://discord.gg/railway

## ✨ You're Ready!

All configuration is complete. Your next step is to:

1. **Set up GitHub OAuth** (see GITHUB_OAUTH_SETUP.md)
2. **Get AI API keys** (OpenAI or Anthropic)
3. **Follow RAILWAY_DEPLOYMENT_GUIDE.md** to deploy

**Happy coding! 🚀**

---

*Generated during Codebuff Railway configuration*
