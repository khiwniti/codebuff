# Using LiteLLM with GitHub Copilot Chat API in Codebuff

This guide shows you how to configure Codebuff to use LiteLLM as a proxy to access GitHub Copilot Chat API.

## 🎯 What is LiteLLM?

LiteLLM is a unified interface to 100+ LLM APIs (OpenAI, Azure, Anthropic, etc.). It can proxy requests to GitHub Copilot Chat API, allowing you to use Copilot's models in Codebuff.

## 📋 Prerequisites

1. **GitHub Copilot subscription** (Individual or Business)
2. **GitHub account** with Copilot access
3. **Python 3.8+** (for running LiteLLM)
4. **Codebuff setup** (already done ✅)

## 🚀 Setup Steps

### Step 1: Install LiteLLM

```bash
# Install LiteLLM
pip install litellm

# Or with uv (faster)
pip install uv
uv pip install litellm
```

### Step 2: Get GitHub Copilot Token

You need to extract your GitHub Copilot token from VS Code or GitHub CLI.

#### Option A: Using GitHub CLI

```bash
# Install GitHub CLI if not already installed
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate
gh auth login

# Get Copilot token
gh copilot token
```

#### Option B: Extract from VS Code

1. Open VS Code with Copilot extension installed
2. Open Developer Tools (Help → Toggle Developer Tools)
3. Go to Console tab
4. Run this command:
   ```javascript
   JSON.parse(localStorage.getItem('github.copilot.token')).token
   ```
5. Copy the token (starts with `ghu_`)

### Step 3: Create LiteLLM Configuration

Create a file `litellm_config.yaml`:

```bash
cd /workspace/codebuff
nano litellm_config.yaml
```

Add this configuration:

```yaml
# LiteLLM Configuration for GitHub Copilot

model_list:
  # GitHub Copilot Chat models
  - model_name: copilot-gpt-4
    litellm_params:
      model: github/gpt-4
      api_base: https://api.githubcopilot.com
      api_key: ${GITHUB_COPILOT_TOKEN}
  
  - model_name: copilot-gpt-3.5-turbo
    litellm_params:
      model: github/gpt-3.5-turbo
      api_base: https://api.githubcopilot.com
      api_key: ${GITHUB_COPILOT_TOKEN}
  
  - model_name: copilot-claude
    litellm_params:
      model: github/claude-3-5-sonnet
      api_base: https://api.githubcopilot.com
      api_key: ${GITHUB_COPILOT_TOKEN}

# Server settings
litellm_settings:
  drop_params: true
  success_callback: ["langfuse"]
  
general_settings:
  master_key: "sk-litellm-master-key-change-this"  # Change this!
```

### Step 4: Start LiteLLM Proxy Server

```bash
# Set your GitHub Copilot token
export GITHUB_COPILOT_TOKEN="ghu_your_copilot_token_here"

# Start LiteLLM proxy
litellm --config litellm_config.yaml --port 8000

# Or run in background
litellm --config litellm_config.yaml --port 8000 > litellm.log 2>&1 &
```

The proxy will start at `http://localhost:8000`

### Step 5: Configure Codebuff to Use LiteLLM

Update your `.env.local` file:

```bash
nano .env.local
```

Add or update these lines:

```bash
# OpenAI-compatible API (LiteLLM proxy)
OPENAI_API_KEY=sk-litellm-master-key-change-this
OPENAI_API_BASE=http://localhost:8000

# Or use as OpenRouter alternative
OPEN_ROUTER_API_KEY=sk-litellm-master-key-change-this
OPEN_ROUTER_API_BASE=http://localhost:8000

# Specify which model to use
DEFAULT_MODEL=copilot-gpt-4
```

### Step 6: Test the Configuration

Create a test script:

```bash
cd /workspace/codebuff
nano test-litellm.sh
```

Add:

```bash
#!/usr/bin/env bash

echo "Testing LiteLLM with GitHub Copilot..."

curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-litellm-master-key-change-this" \
  -d '{
    "model": "copilot-gpt-4",
    "messages": [
      {
        "role": "user",
        "content": "Say hello!"
      }
    ]
  }'
```

Make it executable and run:

```bash
chmod +x test-litellm.sh
./test-litellm.sh
```

### Step 7: Start Codebuff

```bash
# Make sure LiteLLM is running first
# Then start Codebuff
bun run dev
```

## 🔧 Alternative: Using LiteLLM Docker

If you prefer Docker:

```bash
# Create docker-compose.yml for LiteLLM
cat > litellm-docker-compose.yml << 'EOF'
version: '3.8'

services:
  litellm:
    image: ghcr.io/berriai/litellm:main-latest
    ports:
      - "8000:8000"
    environment:
      - GITHUB_COPILOT_TOKEN=${GITHUB_COPILOT_TOKEN}
      - LITELLM_MASTER_KEY=sk-litellm-master-key-change-this
    volumes:
      - ./litellm_config.yaml:/app/config.yaml
    command: ["--config", "/app/config.yaml", "--port", "8000"]
    restart: unless-stopped
EOF

# Start LiteLLM
export GITHUB_COPILOT_TOKEN="ghu_your_token_here"
docker-compose -f litellm-docker-compose.yml up -d

# View logs
docker-compose -f litellm-docker-compose.yml logs -f
```

## 🎨 Advanced Configuration

### Multiple Models

```yaml
model_list:
  # GitHub Copilot
  - model_name: copilot-gpt-4
    litellm_params:
      model: github/gpt-4
      api_base: https://api.githubcopilot.com
      api_key: ${GITHUB_COPILOT_TOKEN}
  
  # Fallback to OpenAI
  - model_name: gpt-4-fallback
    litellm_params:
      model: gpt-4
      api_key: ${OPENAI_API_KEY}
  
  # Local Ollama
  - model_name: local-llama
    litellm_params:
      model: ollama/llama2
      api_base: http://localhost:11434

# Router settings for load balancing
router_settings:
  routing_strategy: usage-based-routing
  model_group_alias:
    gpt-4: [copilot-gpt-4, gpt-4-fallback]
```

### Rate Limiting

```yaml
general_settings:
  master_key: "sk-litellm-master-key-change-this"
  
# Rate limiting per user/model
litellm_settings:
  max_parallel_requests: 100
  global_max_parallel_requests: 1000
  
# Per-model rate limits
model_list:
  - model_name: copilot-gpt-4
    litellm_params:
      model: github/gpt-4
      api_base: https://api.githubcopilot.com
      api_key: ${GITHUB_COPILOT_TOKEN}
      rpm: 60  # requests per minute
      tpm: 100000  # tokens per minute
```

### Caching

```yaml
litellm_settings:
  cache: true
  cache_params:
    type: redis
    host: localhost
    port: 6379
```

## 📝 Environment Variables

Add to `.env.local`:

```bash
# GitHub Copilot Token
GITHUB_COPILOT_TOKEN=ghu_your_copilot_token_here

# LiteLLM Configuration
LITELLM_PROXY_URL=http://localhost:8000
LITELLM_MASTER_KEY=sk-litellm-master-key-change-this

# Use LiteLLM as OpenAI
OPENAI_API_BASE=http://localhost:8000
OPENAI_API_KEY=sk-litellm-master-key-change-this

# Default model
DEFAULT_MODEL=copilot-gpt-4
```

## 🔍 Troubleshooting

### LiteLLM won't start

```bash
# Check if port 8000 is available
lsof -i :8000

# Kill process if needed
kill -9 $(lsof -t -i:8000)

# Check LiteLLM logs
cat litellm.log
```

### Invalid Copilot Token

```bash
# Token expires - get a new one
gh copilot token

# Update environment variable
export GITHUB_COPILOT_TOKEN="new_token_here"

# Restart LiteLLM
pkill -f litellm
litellm --config litellm_config.yaml --port 8000
```

### Codebuff can't connect

```bash
# Test LiteLLM is running
curl http://localhost:8000/health

# Test authentication
curl http://localhost:8000/v1/models \
  -H "Authorization: Bearer sk-litellm-master-key-change-this"

# Check Codebuff can reach it
cd /workspace/codebuff
bun run dev --verbose
```

### GitHub Copilot Rate Limits

GitHub Copilot has rate limits. If you hit them:

1. **Add fallback models** in LiteLLM config
2. **Implement caching** to reduce API calls
3. **Use router with multiple backends**

## 🚀 Production Deployment

### Deploy LiteLLM on Railway

```bash
# Create railway.json for LiteLLM
cat > litellm-railway.json << 'EOF'
{
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile.litellm"
  },
  "deploy": {
    "startCommand": "litellm --config /app/config.yaml --port $PORT",
    "healthcheckPath": "/health",
    "restartPolicyType": "ON_FAILURE"
  }
}
EOF

# Create Dockerfile
cat > Dockerfile.litellm << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN pip install litellm[proxy]

COPY litellm_config.yaml /app/config.yaml

CMD ["litellm", "--config", "/app/config.yaml", "--port", "8000"]
EOF

# Deploy to Railway
railway up
```

Then update Codebuff's `.env.local`:

```bash
OPENAI_API_BASE=https://your-litellm.railway.app
```

## 💡 Best Practices

1. **Secure your master key** - Use a strong random key
2. **Monitor usage** - LiteLLM has built-in analytics
3. **Set rate limits** - Prevent unexpected costs
4. **Use caching** - Reduce API calls
5. **Implement fallbacks** - Multiple model providers
6. **Rotate tokens** - Copilot tokens expire

## 📊 Cost Comparison

| Provider | Model | Cost | Notes |
|----------|-------|------|-------|
| **GitHub Copilot** | GPT-4 | $10-20/month | Included in Copilot subscription |
| **OpenAI Direct** | GPT-4 | $0.03/1K tokens | Pay per use |
| **Anthropic** | Claude 3 | $0.015/1K tokens | Pay per use |

**With Copilot**: You're already paying $10-20/month, so using it for Codebuff is essentially **free**!

## 🎯 Summary

Using LiteLLM with GitHub Copilot gives you:

✅ **Free AI usage** (included in Copilot subscription)
✅ **Unified API** (OpenAI-compatible)
✅ **Multiple models** (GPT-4, Claude, etc.)
✅ **Load balancing** and fallbacks
✅ **Rate limiting** and caching
✅ **Analytics** and monitoring

## 📚 Additional Resources

- **LiteLLM Docs**: https://docs.litellm.ai/
- **GitHub Copilot API**: https://docs.github.com/en/copilot
- **Codebuff SDK**: See `/workspace/codebuff/sdk/`

---

**Questions?**
- LiteLLM Discord: https://discord.com/invite/wuPM9dRgDw
- Codebuff Discord: https://codebuff.com/discord
- GitHub Issues: https://github.com/khiwniti/codebuff-local/issues

**Happy coding with Copilot-powered Codebuff! 🚀**
