# Codebuff CLI Configuration Guide

## 🚀 Quick Setup with Railway Deployment

After running the deployment script, your local CLI can connect to your cloud instance.

### 1. Configure Local CLI for Cloud

```bash
# Update your local .env.local to connect to your deployed instance
NEXT_PUBLIC_CB_ENVIRONMENT=prod
NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-railway-url.railway.app
OPENAI_API_KEY=your_api_key_here
ANTHROPIC_API_KEY=your_api_key_here
OPEN_ROUTER_API_KEY=your_api_key_here
```

### 2. Start CLI with Cloud Backend

```bash
# Use the Makefile for easy commands
make cli

# Or manually:
bun --env-file=.env.local run start-cli
```

## 🌐 Custom Domain Setup

### Railway Custom Domain

1. **In Railway Dashboard:**
   - Go to Settings → Domains
   - Add your custom domain: `codebuff.yourdomain.com`
   - Railway will provide DNS records

2. **DNS Configuration:**

   ```
   # CNAME Record (recommended)
   codebuff.yourdomain.com → cname.railway.app

   # OR A Records
   codebuff.yourdomain.com → 159.89.98.184
   codebuff.yourdomain.com → 159.223.89.197
   ```

3. **Update Environment:**

   ```bash
   # In Railway dashboard
   NEXT_PUBLIC_CODEBUFF_APP_URL=https://codebuff.yourdomain.com
   ```

4. **Re-deploy:**
   ```bash
   railway up
   ```

### Alternative Cloud Providers

#### Vercel Setup

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod

# Set custom domain
vercel domains add codebuff.yourdomain.com
```

#### Netlify Setup

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build and deploy
netlify deploy --prod --dir=web/.next

# Set custom domain in Netlify dashboard
```

#### AWS with CloudFront

```bash
# Build for production
make build-web

# Deploy to S3 + CloudFront
# (See detailed AWS deployment guide)
```

## 🔧 CLI Configuration Options

### Environment-Based Configuration

```bash
# Development (local)
NEXT_PUBLIC_CB_ENVIRONMENT=dev
NEXT_PUBLIC_CODEBUFF_APP_URL=http://localhost:4242

# Staging (Railway)
NEXT_PUBLIC_CB_ENVIRONMENT=test
NEXT_PUBLIC_CODEBUFF_APP_URL=https://staging-codebuff.railway.app

# Production (Custom Domain)
NEXT_PUBLIC_CB_ENVIRONMENT=prod
NEXT_PUBLIC_CODEBUFF_APP_URL=https://codebuff.yourdomain.com
```

### API Provider Configuration

```bash
# OpenAI (GPT models)
OPENAI_API_KEY=sk-proj-...

# Anthropic (Claude models)
ANTHROPIC_API_KEY=sk-ant-...

# OpenRouter (multiple models)
OPEN_ROUTER_API_KEY=sk-or-v1-...

# Claude Code (IDE integration)
CLAUDE_CODE_KEY=sk-ant-...
```

## 📱 Using CLI with Different Environments

### Local Development

```bash
# Uses local backend
make dev
```

### Cloud Connection

```bash
# Connect to your deployed instance
NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-app.railway.app make cli
```

### Production CLI

```bash
# Create production config
cp .env.local .env.production

# Edit .env.production with production values
NEXT_PUBLIC_CB_ENVIRONMENT=prod
NEXT_PUBLIC_CODEBUFF_APP_URL=https://codebuff.yourdomain.com

# Use production config
NEXT_PUBLIC_CODEBUFF_APP_URL=https://codebuff.yourdomain.com bun --env-file=.env.production run start-cli
```

## 🛠️ CLI Commands Reference

### Basic Commands

```bash
# Start CLI
codebuff

# List available agents
codebuff agents

# Run specific agent
codebuff run researcher --query "implement user authentication"

# Work on specific directory
codebuff --cwd /path/to/project

# Use custom configuration
codebuff --config ./custom-config.json
```

### Advanced Usage

```bash
# Run with specific AI provider
OPENAI_API_KEY=... codebuff --provider openai

# Use custom agent
codebuff --agent ./my-custom-agent.ts

# Debug mode
codebuff --debug --log-level verbose

# Performance monitoring
codebuff --profile --output metrics.json
```

## 🔍 Troubleshooting CLI Connection

### Connection Issues

```bash
# Check backend connectivity
curl https://your-app.railway.app/api/healthz

# Verify environment variables
bun --env-file=.env.local run print-env

# Check CLI configuration
codebuff --version
codebuff --config-check
```

### Authentication Problems

```bash
# Clear local auth cache
rm -rf ~/.codebuff/

# Re-authenticate
codebuff auth login

# Check auth status
codebuff auth status
```

### API Key Issues

```bash
# Test API connectivity
curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models

# Verify key format
echo $OPENAI_API_KEY | grep -E "^sk-"
```

## 🚀 Production Best Practices

### Security

```bash
# Use environment-specific configs
.env.local          # Development
.env.staging        # Staging
.env.production     # Production

# Never commit secrets to git
echo ".env.*" >> .gitignore

# Use secret management services
# Railway Variables, AWS Secrets Manager, etc.
```

### Performance

```bash
# Use CDN for static assets
NEXT_PUBLIC_ASSET_URL=https://cdn.yourdomain.com

# Enable caching
NEXT_PUBLIC_CACHE_ENABLED=true

# Monitor usage
NEXT_PUBLIC_ANALYTICS_ENABLED=true
```

### Monitoring

```bash
# Health checks
curl https://codebuff.yourdomain.com/api/healthz

# Log monitoring
railway logs --tail

# Error tracking
# Configure Sentry/LogRocket in environment
```

## 📚 Additional Resources

- **Documentation**: https://codebuff.com/docs
- **Community**: https://codebuff.com/discord
- **Railway Docs**: https://docs.railway.app
- **CLI Reference**: https://codebuff.com/docs/cli
