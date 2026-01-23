# 🚀 Codebuff Setup Complete!

Your Codebuff repository is now configured and ready for deployment to Railway!

## 📦 What's Been Set Up

✅ Repository cloned from GitHub
✅ Bun package manager installed (v1.3.6)
✅ All dependencies installed (1755 packages)
✅ Environment variables configured (.env.local created)
✅ Railway deployment files created

## 📁 New Files Created

- **`RAILWAY_DEPLOYMENT_GUIDE.md`** - Complete Railway deployment instructions
- **`GITHUB_OAUTH_SETUP.md`** - GitHub OAuth setup guide
- **`railway.json`** - Railway deployment configuration
- **`nixpacks.toml`** - Build environment configuration
- **`.env.railway.template`** - Environment variables template for Railway
- **`setup-railway.sh`** - Automated Railway setup script
- **`.env.local`** - Local environment configuration

## 🎯 Quick Start Options

### Option 1: Deploy to Railway (Recommended for Production)

```bash
# 1. Install Railway CLI
npm install -g @railway/cli
# or
curl -fsSL https://railway.app/install.sh | sh

# 2. Run the setup script
./setup-railway.sh

# 3. Follow the prompts to configure your deployment

# 4. Deploy!
railway up
```

**Detailed instructions**: See `RAILWAY_DEPLOYMENT_GUIDE.md`

### Option 2: Run Locally with Docker

```bash
# 1. Start PostgreSQL with Docker Compose
cd packages/internal/src/db
docker-compose up -d

# 2. Run database migrations
bun run db:migrate

# 3. Start the development server
bun run dev
```

**Note**: Docker requires proper networking permissions. In containerized environments, consider using Railway's PostgreSQL instead.

### Option 3: Run Locally Without Docker

If Docker isn't available, you can use an external PostgreSQL instance:

```bash
# 1. Update DATABASE_URL in .env.local to point to your PostgreSQL instance
# Example: postgresql://user:password@your-db-host:5432/codebuff_db

# 2. Run database migrations
bun run db:migrate

# 3. Start the development server
bun run dev
```

## 🔑 Required Configuration

Before running Codebuff, you need to configure:

### 1. GitHub OAuth (Required)
Follow `GITHUB_OAUTH_SETUP.md` to create a GitHub OAuth app and get:
- `CODEBUFF_GITHUB_ID`
- `CODEBUFF_GITHUB_SECRET`

### 2. AI API Keys (At least one required)
Get API keys from:
- **OpenAI**: https://platform.openai.com/api-keys → `OPENAI_API_KEY`
- **Anthropic**: https://console.anthropic.com/ → `ANTHROPIC_API_KEY`
- **Other providers**: OpenRouter, Claude Code, etc.

### 3. NextAuth Secret (Required)
Generate a secure secret:
```bash
openssl rand -base64 32
```
Set this as `NEXTAUTH_SECRET` in your environment.

### 4. Database (Required)
- **Local**: Use Docker Compose (see `packages/internal/src/db/docker-compose.yml`)
- **Railway**: Add PostgreSQL through Railway dashboard (automatic)
- **External**: Any PostgreSQL 16+ instance

## 🌐 Deployment Checklist

- [ ] GitHub OAuth app created and configured
- [ ] At least one AI API key configured
- [ ] `NEXTAUTH_SECRET` generated
- [ ] Database accessible (local Docker or Railway)
- [ ] `NEXT_PUBLIC_CODEBUFF_APP_URL` set to your domain
- [ ] Environment variables configured
- [ ] Database migrations run (`bun run db:migrate`)
- [ ] Application deployed and running

## 📚 Documentation

- **Railway Deployment**: `RAILWAY_DEPLOYMENT_GUIDE.md` - Complete Railway setup
- **GitHub OAuth**: `GITHUB_OAUTH_SETUP.md` - OAuth configuration
- **Contributing**: `CONTRIBUTING.md` - Development guidelines
- **Environment Variables**: `.env.railway.template` - All available variables

## 🛠️ Common Commands

```bash
# Development
bun run dev                  # Start all services
bun run start-web           # Start web server only
bun run start-cli           # Start CLI only

# Building
bun run build               # Build all packages
bun run build:web           # Build web app only

# Database
bun run db:migrate          # Run migrations
bun run db:studio           # Open Drizzle Studio

# Testing
bun test                    # Run tests
bun run typecheck           # Type checking

# Deployment
railway up                  # Deploy to Railway
railway logs                # View logs
railway open                # Open dashboard
```

## 🎓 Next Steps

1. **Set up GitHub OAuth** (see `GITHUB_OAUTH_SETUP.md`)
2. **Get AI API keys** (OpenAI or Anthropic recommended)
3. **Choose deployment method**:
   - For production: Follow `RAILWAY_DEPLOYMENT_GUIDE.md`
   - For local development: Start Docker and run `bun run dev`
4. **Give yourself credits** (see guides for instructions)
5. **Publish agents** (optional, for CLI usage outside project)

## ⚠️ Important Notes

- **Never commit `.env.local` or secrets** to version control
- **Use separate OAuth apps** for development and production
- **Docker limitations**: In containerized environments, Docker may have networking issues. Use Railway PostgreSQL for deployments.
- **Credits system**: After first login, you'll need to manually add credits to your account (see deployment guides)

## 🐛 Troubleshooting

### Build Issues
- **Bun not found**: Make sure Bun is installed and in your PATH
- **Dependencies failed**: Try `rm -rf node_modules && bun install`

### Database Issues
- **Connection refused**: Ensure PostgreSQL is running and `DATABASE_URL` is correct
- **Migration errors**: Make sure database exists and credentials are correct

### Authentication Issues
- **GitHub OAuth errors**: Verify callback URL matches exactly
- **NextAuth errors**: Check `NEXTAUTH_SECRET` is set and valid

### Railway Deployment Issues
- **Build timeout**: Increase timeout in Railway settings
- **Missing env vars**: Double-check all required variables are set

See the full deployment guides for detailed troubleshooting.

## 📖 Resources

- **Codebuff Website**: https://codebuff.com
- **Documentation**: https://codebuff.com/docs
- **Discord Community**: https://codebuff.com/discord
- **GitHub Repository**: https://github.com/CodebuffAI/codebuff
- **Railway Documentation**: https://docs.railway.app

## 🤝 Need Help?

- **Discord**: Join the Codebuff Discord for community support
- **GitHub Issues**: Report bugs or request features
- **Documentation**: Check the docs for detailed guides

## 🎉 You're All Set!

Your Codebuff instance is configured and ready to deploy. Choose your deployment method and follow the corresponding guide.

**Recommended**: Start with `GITHUB_OAUTH_SETUP.md`, then proceed to `RAILWAY_DEPLOYMENT_GUIDE.md` for production deployment.

---

**Happy coding! 🚀**
