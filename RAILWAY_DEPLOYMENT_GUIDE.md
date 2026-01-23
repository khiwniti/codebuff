# Codebuff Railway Deployment Guide

This guide will walk you through deploying Codebuff to Railway, including setting up the database, web server, and all required services.

## Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **GitHub Account**: For OAuth authentication
3. **GitHub Repository**: Fork or use the official Codebuff repository
4. **API Keys**: You'll need API keys for AI providers (OpenAI, Anthropic, etc.)

## Step 1: Install Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Or with curl
curl -fsSL https://railway.app/install.sh | sh

# Login to Railway
railway login
```

## Step 2: Set Up GitHub OAuth Application

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in the details:
   - **Application name**: Codebuff (or your preferred name)
   - **Homepage URL**: `https://your-app.railway.app` (you'll update this after deployment)
   - **Authorization callback URL**: `https://your-app.railway.app/api/auth/callback/github`
4. Click "Register application"
5. Note your **Client ID** and generate a **Client Secret**

## Step 3: Create Railway Project

```bash
# Navigate to your codebuff directory
cd /workspace/codebuff

# Initialize Railway project
railway init

# Or link to existing project
# railway link
```

## Step 4: Add PostgreSQL Database

```bash
# Add PostgreSQL to your Railway project
railway add --database postgres
```

This will automatically create a PostgreSQL database and set the `DATABASE_URL` environment variable.

## Step 5: Configure Environment Variables

You need to set up environment variables in Railway. You can do this via:
- Railway Dashboard (recommended for initial setup)
- Railway CLI

### Required Environment Variables

```bash
# AI API Keys (at least one required)
railway variables set OPENAI_API_KEY=your_openai_key_here
railway variables set ANTHROPIC_API_KEY=your_anthropic_key_here
# railway variables set CLAUDE_CODE_KEY=your_claude_code_key
# railway variables set OPEN_ROUTER_API_KEY=your_openrouter_key

# Database (automatically set by Railway when you add PostgreSQL)
# DATABASE_URL=postgresql://user:password@host:port/database

# Authentication
railway variables set CODEBUFF_GITHUB_ID=your_github_client_id
railway variables set CODEBUFF_GITHUB_SECRET=your_github_client_secret
railway variables set NEXTAUTH_SECRET=$(openssl rand -base64 32)

# Server Configuration
railway variables set PORT=3000
railway variables set NODE_ENV=production

# Frontend/Public Variables
railway variables set NEXT_PUBLIC_CB_ENVIRONMENT=production
railway variables set NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-app.railway.app
railway variables set NEXT_PUBLIC_SUPPORT_EMAIL=support@yourdomain.com

# Optional: Payment (Stripe) - if you want billing
# railway variables set STRIPE_SECRET_KEY=sk_live_your_stripe_secret
# railway variables set STRIPE_WEBHOOK_SECRET_KEY=whsec_your_webhook_secret
# railway variables set STRIPE_USAGE_PRICE_ID=price_your_usage_id
# railway variables set STRIPE_TEAM_FEE_PRICE_ID=price_your_team_fee_id
# railway variables set NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_your_publishable_key

# Optional: External Services
# railway variables set LINKUP_API_KEY=your_linkup_key
# railway variables set LOOPS_API_KEY=your_loops_key

# Optional: Analytics
# railway variables set NEXT_PUBLIC_POSTHOG_API_KEY=your_posthog_key
# railway variables set NEXT_PUBLIC_POSTHOG_HOST_URL=https://us.i.posthog.com
```

### Setting Variables via Dashboard

1. Go to your Railway project dashboard
2. Click on your service
3. Go to the "Variables" tab
4. Add each environment variable

## Step 6: Create railway.json Configuration

The project needs a `railway.json` file to configure the build and deployment:

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "bun install && bun run build"
  },
  "deploy": {
    "startCommand": "bun run start",
    "healthcheckPath": "/api/health",
    "healthcheckTimeout": 100,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

## Step 7: Create Nixpacks Configuration

Create a `nixpacks.toml` file for build configuration:

```toml
[phases.setup]
nixPkgs = ["nodejs", "bun"]

[phases.install]
cmds = ["bun install"]

[phases.build]
cmds = ["bun run build"]

[start]
cmd = "bun run start"
```

## Step 8: Update package.json Scripts

Ensure your `package.json` has the proper scripts:

```json
{
  "scripts": {
    "dev": "bun run start-web",
    "build": "bun run build:web",
    "start": "bun run start:web",
    "build:web": "cd web && bun run build",
    "start:web": "cd web && bun run start",
    "db:migrate": "cd packages/internal && bun run db:migrate",
    "db:studio": "cd packages/internal && bun run db:studio"
  }
}
```

## Step 9: Run Database Migrations

After your first deployment, you need to run database migrations:

```bash
# Connect to your Railway project
railway link

# Run migrations
railway run bun --cwd packages/internal run db:migrate
```

Or you can add this to your build command in `railway.json` (already configured):

```json
{
  "build": {
    "buildCommand": "bun install && bun --cwd packages/internal run db:migrate && bun --cwd web run build"
  }
}
```

## Step 10: Deploy to Railway

```bash
# Deploy from current directory
railway up

# Or connect GitHub repository for automatic deployments
# This is done through the Railway dashboard:
# 1. Go to your project settings
# 2. Connect GitHub repository
# 3. Select the repository and branch
# 4. Railway will automatically deploy on push
```

## Step 11: Update GitHub OAuth Callback URL

After deployment, update your GitHub OAuth app:

1. Get your Railway deployment URL (e.g., `https://your-app-name.up.railway.app`)
2. Go to your GitHub OAuth app settings
3. Update:
   - **Homepage URL**: `https://your-app-name.up.railway.app`
   - **Authorization callback URL**: `https://your-app-name.up.railway.app/api/auth/callback/github`
4. Update the environment variable in Railway:
   ```bash
   railway variables set NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-app-name.up.railway.app
   ```

## Step 12: Set Up Custom Domain (Optional)

1. Go to Railway dashboard → Your service → Settings
2. Click "Generate Domain" for a railway.app subdomain
3. Or add your custom domain:
   - Click "Custom Domain"
   - Enter your domain
   - Add the DNS records shown in Railway to your domain registrar
   - Railway will automatically provision SSL certificates

## Step 13: Initial Setup - Give Yourself Credits

After deployment, you need to set up credits:

1. Log into your deployed Codebuff at your Railway URL
2. Open a Railway shell:
   ```bash
   railway shell
   ```
3. Connect to the database:
   ```bash
   railway connect postgres
   ```
4. Run SQL to give yourself credits:
   ```sql
   -- Find your user ID
   SELECT * FROM users WHERE email = 'your@email.com';
   
   -- Insert credits (replace USER_ID with your actual user ID)
   INSERT INTO credit_ledger (user_id, principal, balance, created_at)
   VALUES ('USER_ID', 1000000, 1000000, NOW());
   ```

Or use Drizzle Studio:
```bash
# Run locally pointing to Railway database
railway run bun run db:studio
```

## Step 14: Publish Agents (Optional)

To use agents in directories outside the project:

1. Create a publisher profile at `https://your-app.railway.app/publishers`
   - Set `publisher_id` to `codebuff`

2. Publish agents:
   ```bash
   railway run bun start-cli publish base context-pruner file-explorer file-picker researcher thinker reviewer
   ```

## Troubleshooting

### Build Failures

- **Issue**: Bun not found
  - **Solution**: Ensure `nixpacks.toml` includes `bun` in nixPkgs

- **Issue**: Build timeout
  - **Solution**: Increase timeout in Railway settings or optimize build

### Runtime Errors

- **Issue**: Database connection errors
  - **Solution**: Verify `DATABASE_URL` is set and database is running

- **Issue**: Authentication not working
  - **Solution**: Double-check GitHub OAuth credentials and callback URL

### Performance Issues

- **Issue**: Slow response times
  - **Solution**: Upgrade Railway plan or optimize queries

- **Issue**: Memory issues
  - **Solution**: Monitor memory usage and upgrade plan if needed

## Monitoring and Logs

```bash
# View logs
railway logs

# Follow logs
railway logs -f

# View specific service logs
railway logs -s your-service-name
```

## Cost Optimization

1. **Use Shared Database**: Start with shared PostgreSQL, upgrade if needed
2. **Set Sleep Settings**: Configure service to sleep when inactive (Hobby plan)
3. **Monitor Usage**: Check Railway dashboard for usage metrics
4. **Optimize Build**: Cache dependencies to speed up builds

## Useful Railway Commands

```bash
# View environment variables
railway variables

# Open project in browser
railway open

# Connect to shell
railway shell

# Connect to database
railway connect postgres

# View project status
railway status

# Delete service
railway delete
```

## Additional Resources

- [Railway Documentation](https://docs.railway.app/)
- [Codebuff Documentation](https://codebuff.com/docs)
- [Railway Discord Community](https://discord.gg/railway)
- [Codebuff Discord](https://codebuff.com/discord)

## Production Checklist

- [ ] Environment variables configured
- [ ] GitHub OAuth app set up with correct callback URL
- [ ] Database migrations run
- [ ] AI API keys configured (at least one provider)
- [ ] Custom domain configured (optional)
- [ ] SSL certificate active
- [ ] Credits set up for initial users
- [ ] Monitoring enabled
- [ ] Backup strategy in place
- [ ] Stripe configured (if using billing)

## Security Considerations

1. **Never commit `.env.local` or secrets to git**
2. **Use strong NEXTAUTH_SECRET** (generated with `openssl rand -base64 32`)
3. **Rotate API keys regularly**
4. **Use Railway's secrets management** for sensitive data
5. **Enable 2FA on Railway account**
6. **Review Railway access logs** periodically
7. **Set up monitoring and alerts** for suspicious activity

## Scaling

As your application grows:

1. **Vertical Scaling**: Upgrade Railway plan for more resources
2. **Horizontal Scaling**: Consider adding multiple instances (Pro plan)
3. **Database Optimization**: Add indices, optimize queries
4. **Caching**: Implement Redis for session/cache management
5. **CDN**: Use Railway's CDN or external CDN for static assets

## Next Steps

After successful deployment:

1. Test all functionality
2. Set up monitoring and alerts
3. Configure backups
4. Document your specific configuration
5. Train team members on the system
6. Plan for scaling as needed

---

**Need Help?**
- Railway Discord: https://discord.gg/railway
- Codebuff Discord: https://codebuff.com/discord
- GitHub Issues: https://github.com/CodebuffAI/codebuff/issues
