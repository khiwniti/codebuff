# 🚀 LiteLLM + Copilot Quick Start

## ⚡ Ultra-Fast Setup

```bash
# 1. Run setup script
./setup-litellm.sh

# 2. Start LiteLLM
./start-litellm.sh

# 3. Test it
./test-litellm.sh

# 4. Start Codebuff
bun run dev
```

## 🐳 Docker Setup (Even Easier!)

```bash
# 1. Get GitHub Copilot token
gh copilot token

# 2. Create .env file for Docker
cat > .env.litellm << 'EOF'
GITHUB_COPILOT_TOKEN=your_token_here
LITELLM_MASTER_KEY=sk-litellm-your-secure-key
EOF

# 3. Create minimal config
cat > litellm_config.yaml << 'EOF'
model_list:
  - model_name: copilot-gpt-4
    litellm_params:
      model: github/gpt-4
      api_base: https://api.githubcopilot.com
      api_key: ${GITHUB_COPILOT_TOKEN}
EOF

# 4. Start with Docker
docker-compose -f docker-compose.litellm.yml --env-file .env.litellm up -d

# 5. Check logs
docker-compose -f docker-compose.litellm.yml logs -f litellm

# 6. Update Codebuff .env.local
echo "OPENAI_API_BASE=http://localhost:8000" >> .env.local
echo "OPENAI_API_KEY=sk-litellm-your-secure-key" >> .env.local

# 7. Start Codebuff
bun run dev
```

## 📋 Prerequisites

- ✅ GitHub Copilot subscription ($10-20/month)
- ✅ Python 3.8+ OR Docker
- ✅ Codebuff setup (done!)

## 🔑 Get Copilot Token

### Option 1: GitHub CLI
```bash
gh auth login
gh copilot token
```

### Option 2: VS Code
1. Open VS Code → Help → Toggle Developer Tools
2. Console tab
3. Run: `JSON.parse(localStorage.getItem('github.copilot.token')).token`

## 🛠️ Manual Setup

### Install LiteLLM
```bash
pip install litellm
```

### Create Config
```yaml
# litellm_config.yaml
model_list:
  - model_name: copilot-gpt-4
    litellm_params:
      model: github/gpt-4
      api_base: https://api.githubcopilot.com
      api_key: ghu_your_token_here
```

### Start LiteLLM
```bash
litellm --config litellm_config.yaml --port 8000
```

### Configure Codebuff
```bash
# .env.local
OPENAI_API_BASE=http://localhost:8000
OPENAI_API_KEY=sk-any-key
```

## 🎯 Available Models

| Model Name | Description | Cost |
|------------|-------------|------|
| `copilot-gpt-4` | GPT-4 via Copilot | Included |
| `copilot-gpt-3.5-turbo` | GPT-3.5 via Copilot | Included |
| `copilot-claude` | Claude 3.5 via Copilot | Included |

## 🔧 Useful Commands

```bash
# Start LiteLLM
./start-litellm.sh
# OR
litellm --config litellm_config.yaml --port 8000

# Stop LiteLLM
./stop-litellm.sh
# OR
pkill -f litellm

# Test LiteLLM
./test-litellm.sh
# OR
curl http://localhost:8000/health

# View available models
curl http://localhost:8000/v1/models

# Docker commands
docker-compose -f docker-compose.litellm.yml up -d    # Start
docker-compose -f docker-compose.litellm.yml logs -f   # Logs
docker-compose -f docker-compose.litellm.yml down      # Stop
```

## 💰 Cost Savings

### Without LiteLLM/Copilot
- OpenAI GPT-4: ~$0.03/1K tokens = $30-100/month

### With GitHub Copilot
- GitHub Copilot: $10-20/month (flat fee)
- **Unlimited usage** of GPT-4, GPT-3.5, Claude
- **Save $10-80/month!**

## 🐛 Troubleshooting

### LiteLLM won't start
```bash
# Check if port 8000 is busy
lsof -i :8000

# Kill existing process
kill -9 $(lsof -t -i:8000)

# Try different port
litellm --config litellm_config.yaml --port 8001
```

### Invalid token
```bash
# Token expires every few hours - get new one
gh copilot token

# Update config and restart
```

### Codebuff can't connect
```bash
# Test LiteLLM is running
curl http://localhost:8000/health

# Check .env.local has correct settings
grep OPENAI_API_BASE .env.local
```

## 🚀 Production Tips

1. **Use Docker** for reliability
2. **Enable caching** (Redis) to reduce API calls
3. **Set rate limits** to control usage
4. **Monitor logs** for errors
5. **Rotate tokens** regularly

## 📚 More Info

- **Complete Guide**: `LITELLM_COPILOT_SETUP.md`
- **LiteLLM Docs**: https://docs.litellm.ai/
- **Copilot API**: https://docs.github.com/en/copilot

## ✨ Summary

**3 Steps to Use Copilot with Codebuff:**

1. **Get token**: `gh copilot token`
2. **Start LiteLLM**: `./setup-litellm.sh`
3. **Use Codebuff**: `bun run dev`

**Benefits:**
- ✅ Free GPT-4 (included in Copilot)
- ✅ Simple setup
- ✅ OpenAI-compatible API
- ✅ Save money!

---

**Need help?** See `LITELLM_COPILOT_SETUP.md` for detailed instructions!
