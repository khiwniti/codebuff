# Codebuff Railway Deployment Checklist

## 🚀 Pre-Deployment Checklist

### ✅ Repository Ready

- [ ] All code committed to main/develop branch
- [ ] No sensitive data in code (API keys, secrets)
- [ ] `.env.example` is up to date
- [ ] Railway configuration files present:
  - [ ] `railway.toml`
  - [ ] `Dockerfile`
  - [ ] `.dockerignore`

### ✅ Environment Variables

- [ ] Generate `NEXTAUTH_SECRET`: `openssl rand -base64 32`
- [ ] GitHub OAuth App created
- [ ] GitHub Client ID and Secret ready
- [ ] AI API keys available:
  - [ ] `OPENAI_API_KEY` (optional)
  - [ ] `ANTHROPIC_API_KEY` (optional)
  - [ ] `OPEN_ROUTER_API_KEY` (optional)
  - [ ] `CLAUDE_CODE_KEY` (optional)
- [ ] Payment keys (if using Stripe):
  - [ ] `STRIPE_SECRET_KEY`
  - [ ] `STRIPE_WEBHOOK_SECRET_KEY`
  - [ ] `STRIPE_USAGE_PRICE_ID`
  - [ ] `STRIPE_TEAM_FEE_PRICE_ID`

## 🛠️ Deployment Steps

### ✅ Railway Setup

- [ ] Railway CLI installed: `npm install -g @railway/cli`
- [ ] Logged in to Railway: `railway login`
- [ ] New project created: `railway init`
- [ ] PostgreSQL database added: `railway add --database postgres`

### ✅ Environment Configuration

- [ ] Core variables set in Railway:
  - [ ] `NEXTAUTH_SECRET`
  - [ ] `NEXT_PUBLIC_CB_ENVIRONMENT=prod`
  - [ ] `NODE_ENV=production`
- [ ] GitHub OAuth variables set:
  - [ ] `CODEBUFF_GITHUB_ID`
  - [ ] `CODEBUFF_GITHUB_SECRET`
- [ ] AI provider keys set:
  - [ ] `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`
  - [ ] `OPEN_ROUTER_API_KEY`
- [ ] Public URL variables set:
  - [ ] `NEXT_PUBLIC_CODEBUFF_APP_URL` (will update after deployment)

### ✅ Deployment Process

- [ ] Deploy application: `railway up`
- [ ] Wait for deployment to complete
- [ ] Get Railway URL: `railway domain -s`
- [ ] Update GitHub OAuth callback URL
- [ ] Run database migrations: `railway run bun run db:migrate`
- [ ] Test application functionality

### ✅ Post-Deployment Verification

- [ ] Application loads correctly at Railway URL
- [ ] GitHub OAuth authentication works
- [ ] Database connections successful
- [ ] AI providers respond correctly
- [ ] User registration/login works
- [ ] Agent functionality tests pass

## 🌐 Custom Domain Setup (Optional)

### ✅ DNS Configuration

- [ ] Custom domain added in Railway dashboard
- [ ] DNS records configured:
  - [ ] CNAME: `codebuff.yourdomain.com → cname.railway.app`
  - [ ] OR A records pointing to Railway IPs
- [ ] DNS propagation completed (usually 5-30 minutes)
- [ ] SSL certificate provisioned (automatic with Railway)

### ✅ Environment Update

- [ ] `NEXT_PUBLIC_CODEBUFF_APP_URL` updated to custom domain
- [ ] GitHub OAuth callback URL updated
- [ ] Application re-deployed: `railway up`
- [ ] Custom domain resolves correctly
- [ ] HTTPS works properly

## 📱 CLI Configuration

### ✅ Local CLI Setup

- [ ] Local `.env.local` updated with production URL:
  ```
  NEXT_PUBLIC_CB_ENVIRONMENT=prod
  NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-railway-url.railway.app
  ```
- [ ] CLI connects to production instance: `make cli`
- [ ] Authentication works with production backend
- [ ] Agent execution works in cloud environment

### ✅ Production CLI Testing

- [ ] Test basic CLI commands
- [ ] Test agent execution
- [ ] Test file operations (if enabled)
- [ ] Test authentication flow

## 🔧 Production Readiness

### ✅ Security

- [ ] All secrets in Railway variables (not in code)
- [ ] HTTPS enforced
- [ ] GitHub OAuth properly configured
- [ ] API keys have appropriate permissions
- [ ] No debug endpoints exposed in production

### ✅ Performance

- [ ] Application builds successfully
- [ ] Database queries optimized
- [ ] Static assets served efficiently
- [ ] Error handling in place
- [ ] Logging configured appropriately

### ✅ Monitoring

- [ ] Railway monitoring enabled
- [ ] Error tracking configured (optional)
- [ ] Health check endpoint accessible: `/api/healthz`
- [ ] Log access working: `railway logs`

## 🚨 Rollback Plan

### ✅ Backup Strategy

- [ ] Database export before major changes
- [ ] Previous deployment version noted
- [ ] Rollback procedure documented

### ✅ Emergency Contacts

- [ ] Railway support channels identified
- [ ] Team notification system set up
- [ ] Incident response plan ready

## 📊 Ongoing Maintenance

### ✅ Regular Tasks

- [ ] Monitor resource usage in Railway dashboard
- [ ] Check for dependency updates
- [ ] Review error logs regularly
- [ ] Backup database periodically
- [ ] Update API keys as needed

### ✅ Scaling Considerations

- [ ] Monitor performance metrics
- [ ] Plan for traffic increases
- [ ] Database scaling strategy
- [ ] CDN configuration if needed

## 🎯 Success Criteria

Your deployment is successful when:

1. ✅ **Application Access**: Users can access the app at your domain
2. ✅ **Authentication**: GitHub OAuth login works correctly
3. ✅ **Core Features**: Main functionality works as expected
4. ✅ **CLI Integration**: Local CLI can connect to cloud instance
5. ✅ **Performance**: Application loads quickly and is responsive
6. ✅ **Reliability**: Application stays online and handles errors gracefully

## 🆘 Troubleshooting

### Common Issues and Solutions

| Issue                     | Solution                                                          |
| ------------------------- | ----------------------------------------------------------------- |
| Build fails               | Check `railway logs`, ensure all dependencies are in package.json |
| Database connection error | Verify DATABASE_URL, check if migrations ran                      |
| OAuth failure             | Check GitHub OAuth app settings, callback URL must match exactly  |
| API errors                | Verify API keys are correct and have sufficient permissions       |
| Custom domain not working | Check DNS configuration, wait for propagation                     |
| CLI can't connect         | Verify NEXT_PUBLIC_CODEBUFF_APP_URL is correct                    |

## 📞 Support Resources

- **Railway Documentation**: https://docs.railway.app
- **Codebuff Documentation**: https://codebuff.com/docs
- **Codebuff Discord**: https://codebuff.com/discord
- **GitHub Issues**: https://github.com/CodebuffAI/codebuff/issues
