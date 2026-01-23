# 🎉 Codebuff CLI - No Subscription Required!

## ✅ Good News: Codebuff CLI is Free for Local Use

The Codebuff CLI does **NOT** require a subscription to work. The subscription/credits system is only for the **hosted web version** at https://codebuff.com.

## 📦 What You Get for Free

### Local CLI (100% Free)
- ✅ Full CLI functionality
- ✅ All AI-powered coding features
- ✅ All agents and tools
- ✅ SDK access
- ✅ Local development environment
- ✅ **No subscription needed**
- ✅ **No credits required**

### What Requires Subscription
- ❌ Only the hosted web version at codebuff.com
- ❌ Cloud-hosted agents
- ❌ Team features on the hosted platform

## 🚀 How to Use Codebuff CLI Locally (Free)

### Requirements

1. **Bun** ✅ (already installed: v1.3.6)
2. **PostgreSQL** (local or external)
3. **AI API Key** (one of):
   - OpenAI API key (from https://platform.openai.com/api-keys)
   - Anthropic API key (from https://console.anthropic.com/)
   - OpenRouter API key
   - Or any other supported provider

### Setup Steps

```bash
# 1. You're already in the codebuff directory
cd /workspace/codebuff

# 2. Dependencies already installed ✅

# 3. Configure your AI API key in .env.local
# Edit .env.local and add your real API key:
# OPENAI_API_KEY=sk-your-real-key-here
# OR
# ANTHROPIC_API_KEY=sk-ant-your-real-key-here

# 4. Set up database (choose one option):

## Option A: Local PostgreSQL with Docker
cd packages/internal/src/db
docker-compose up -d
cd /workspace/codebuff

## Option B: Use Railway PostgreSQL (free tier)
# See RAILWAY_DEPLOYMENT_GUIDE.md

## Option C: Use any external PostgreSQL
# Update DATABASE_URL in .env.local

# 5. Run migrations
bun run db:migrate

# 6. Start the CLI
bun run dev
```

## 💡 Understanding the Architecture

### CLI Mode (Free, Local)
```
Your Machine
├── Codebuff CLI (free)
├── Local PostgreSQL (free)
└── Your AI API Key (pay per use to OpenAI/Anthropic)
```

- **No subscription**: CLI is open source
- **No credits**: Not needed for local use
- **You only pay**: For AI API calls to your provider (OpenAI, Anthropic, etc.)

### Web Mode (Hosted, Requires Subscription)
```
codebuff.com
├── Hosted Web UI (subscription required)
├── Shared infrastructure (subscription required)
└── Includes AI API costs (credits system)
```

- **Subscription needed**: For hosted convenience
- **Credits system**: Covers AI API costs
- **Team features**: Collaboration, shared agents

## 🔑 API Keys (What You Actually Pay For)

### OpenAI
- **Cost**: Pay-per-use directly to OpenAI
- **Pricing**: https://openai.com/pricing
- **Example**: ~$0.01-0.03 per 1K tokens (GPT-4)
- **Your control**: Set spending limits in OpenAI dashboard

### Anthropic (Claude)
- **Cost**: Pay-per-use directly to Anthropic
- **Pricing**: https://www.anthropic.com/pricing
- **Example**: ~$0.015 per 1K tokens (Claude 3)
- **Your control**: Manage in Anthropic console

### OpenRouter
- **Cost**: Pay-per-use to OpenRouter
- **Benefit**: Access multiple providers with one API
- **Pricing**: https://openrouter.ai/docs#models

## 🎯 No Subscription Workflow

```bash
# Day 1: Setup (one time)
1. Install Bun ✅ (done)
2. Clone/configure Codebuff ✅ (done)
3. Get AI API key (OpenAI or Anthropic)
4. Set up local PostgreSQL
5. Run migrations

# Day 2+: Daily use (free!)
bun run dev
# Use Codebuff CLI as much as you want!
# You only pay for AI API calls (usually pennies)
```

## 💰 Cost Comparison

### Local Setup (This Project)
- **Initial**: $0
- **Monthly subscription**: $0
- **Ongoing**: Only AI API usage
  - Light use: ~$1-5/month
  - Medium use: ~$10-20/month
  - Heavy use: ~$50-100/month
- **Total control**: You manage AI spending

### Hosted Codebuff.com
- **Subscription**: $20-50+/month (hypothetical, check actual pricing)
- **Includes**: Infrastructure + AI API costs
- **Convenience**: No setup needed

## 🛠️ Testing Your Setup

Run the test script:

```bash
./test-cli-local.sh
```

This will verify:
- ✅ Bun is installed
- ✅ Dependencies are ready  
- ✅ Environment is configured
- ✅ CLI can start

## 📝 Important Notes

### About Credits
- **Credits are ONLY for codebuff.com hosted version**
- **Local CLI does NOT use credits**
- **You can ignore all credit-related documentation** for local use

### About Subscriptions
- **No subscription needed** for local CLI
- **Open source and free** to self-host
- **Subscription only** if you want hosted convenience

### About Database
- **Required for CLI** (stores state, agents, etc.)
- **Free options**:
  - Local PostgreSQL with Docker
  - Railway free tier
  - Supabase free tier
  - Any PostgreSQL provider

## 🚀 Quick Start Without Subscription

```bash
# 1. Add your AI API key to .env.local
nano .env.local
# Change: OPENAI_API_KEY=dummy_openai_key
# To: OPENAI_API_KEY=sk-your-real-openai-key

# 2. Set up database (easiest: Railway free tier)
# See RAILWAY_DEPLOYMENT_GUIDE.md for PostgreSQL setup

# 3. Run migrations
bun run db:migrate

# 4. Start CLI
bun run dev

# That's it! No subscription needed! 🎉
```

## 🔧 Troubleshooting

### "Credits required" error
- **This shouldn't happen in local mode**
- Make sure you're running the CLI locally, not connecting to codebuff.com
- Check your DATABASE_URL points to your local/Railway database

### "Authentication required"
- **Local CLI may not need auth** for basic features
- If needed, set up GitHub OAuth (see GITHUB_OAUTH_SETUP.md)
- Or skip auth for local development

### "Database connection error"
- Make sure PostgreSQL is running
- Check DATABASE_URL in .env.local
- Run `bun run start-db` if using Docker

## 📚 Related Documentation

- **SETUP_COMPLETE.md** - Overall setup guide
- **RAILWAY_DEPLOYMENT_GUIDE.md** - Deploy your own instance
- **QUICK_REFERENCE.md** - Command reference
- **CONTRIBUTING.md** - Development guide

## 🎓 Understanding the Business Model

### Open Source (Free)
- **Code**: Apache 2.0 license
- **Self-hosting**: Completely free
- **CLI**: Free to use

### Hosted Service (Paid)
- **Convenience**: No setup needed
- **Team features**: Collaboration tools
- **Managed infrastructure**: They handle everything

**You're using the open source version, which is FREE!** 🎉

## ✨ Summary

**Codebuff CLI = FREE**

You only need:
1. This code base ✅ (you have it)
2. Bun ✅ (installed)
3. PostgreSQL (local or free tier)
4. AI API key (pay-per-use to OpenAI/Anthropic)

**NO SUBSCRIPTION REQUIRED!**

---

**Questions?**
- Check the original README.md
- See CONTRIBUTING.md for development
- Visit https://codebuff.com/discord for community support

**Enjoy your free, self-hosted Codebuff! 🚀**
