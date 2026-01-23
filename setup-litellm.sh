#!/usr/bin/env bash

# Quick LiteLLM Setup for GitHub Copilot
# This script helps you set up LiteLLM to use with Codebuff

set -e

echo "🚀 LiteLLM + GitHub Copilot Setup for Codebuff"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 not found${NC}"
    echo "Please install Python 3.8+ first"
    exit 1
fi

echo -e "${GREEN}✓ Python found: $(python3 --version)${NC}"
echo ""

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}✗ pip3 not found${NC}"
    echo "Please install pip3 first"
    exit 1
fi

echo -e "${GREEN}✓ pip3 found${NC}"
echo ""

# Ask if user wants to install LiteLLM
read -p "Install LiteLLM? (y/n): " install_litellm

if [ "$install_litellm" = "y" ] || [ "$install_litellm" = "Y" ]; then
    echo ""
    echo -e "${BLUE}Installing LiteLLM...${NC}"
    pip3 install litellm
    echo -e "${GREEN}✓ LiteLLM installed${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GET GITHUB COPILOT TOKEN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "You need a GitHub Copilot token. Choose an option:"
echo ""
echo "Option 1: Using GitHub CLI (recommended)"
echo "  $ gh auth login"
echo "  $ gh copilot token"
echo ""
echo "Option 2: Extract from VS Code"
echo "  1. Open VS Code Developer Tools (Help → Toggle Developer Tools)"
echo "  2. Go to Console tab"
echo "  3. Run: JSON.parse(localStorage.getItem('github.copilot.token')).token"
echo ""

read -p "Enter your GitHub Copilot token (starts with ghu_): " copilot_token

if [ -z "$copilot_token" ]; then
    echo -e "${RED}✗ No token provided${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Token received${NC}"
echo ""

# Create LiteLLM config
echo -e "${BLUE}Creating LiteLLM configuration...${NC}"

cat > litellm_config.yaml << EOF
# LiteLLM Configuration for GitHub Copilot

model_list:
  # GitHub Copilot GPT-4
  - model_name: copilot-gpt-4
    litellm_params:
      model: github/gpt-4
      api_base: https://api.githubcopilot.com
      api_key: ${copilot_token}
  
  # GitHub Copilot GPT-3.5
  - model_name: copilot-gpt-3.5-turbo
    litellm_params:
      model: github/gpt-3.5-turbo
      api_base: https://api.githubcopilot.com
      api_key: ${copilot_token}

# Server settings
litellm_settings:
  drop_params: true
  
general_settings:
  master_key: "sk-litellm-$(openssl rand -hex 16)"
EOF

master_key=$(grep "master_key:" litellm_config.yaml | cut -d'"' -f2)

echo -e "${GREEN}✓ Config created: litellm_config.yaml${NC}"
echo ""

# Update .env.local
echo -e "${BLUE}Updating .env.local...${NC}"

# Backup .env.local
cp .env.local .env.local.backup

# Add LiteLLM settings
cat >> .env.local << EOF

# LiteLLM + GitHub Copilot Configuration
OPENAI_API_BASE=http://localhost:8000
OPENAI_API_KEY=${master_key}
DEFAULT_MODEL=copilot-gpt-4
EOF

echo -e "${GREEN}✓ .env.local updated${NC}"
echo "  (backup saved to .env.local.backup)"
echo ""

# Create start script
cat > start-litellm.sh << 'EOF'
#!/usr/bin/env bash

echo "Starting LiteLLM proxy..."
litellm --config litellm_config.yaml --port 8000
EOF

chmod +x start-litellm.sh

# Create stop script
cat > stop-litellm.sh << 'EOF'
#!/usr/bin/env bash

echo "Stopping LiteLLM..."
pkill -f "litellm --config"
echo "LiteLLM stopped"
EOF

chmod +x stop-litellm.sh

# Create test script
cat > test-litellm.sh << EOF
#!/usr/bin/env bash

echo "Testing LiteLLM connection..."
curl http://localhost:8000/health

echo ""
echo "Testing Copilot GPT-4..."
curl http://localhost:8000/v1/chat/completions \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Bearer ${master_key}" \\
  -d '{
    "model": "copilot-gpt-4",
    "messages": [{"role": "user", "content": "Say hello!"}],
    "max_tokens": 50
  }'
EOF

chmod +x test-litellm.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📝 Files created:"
echo "  • litellm_config.yaml - LiteLLM configuration"
echo "  • start-litellm.sh - Start LiteLLM proxy"
echo "  • stop-litellm.sh - Stop LiteLLM proxy"
echo "  • test-litellm.sh - Test the setup"
echo "  • .env.local updated with LiteLLM settings"
echo ""

echo "🚀 Next steps:"
echo ""
echo "1. Start LiteLLM proxy:"
echo "   ${BLUE}./start-litellm.sh${NC}"
echo ""
echo "2. In another terminal, test it:"
echo "   ${BLUE}./test-litellm.sh${NC}"
echo ""
echo "3. Start Codebuff:"
echo "   ${BLUE}bun run dev${NC}"
echo ""

echo "💡 Tips:"
echo "  • LiteLLM runs on http://localhost:8000"
echo "  • Your master key: ${master_key}"
echo "  • Copilot token expires - get new one with: gh copilot token"
echo ""

echo "📚 For more info, see: LITELLM_COPILOT_SETUP.md"
echo ""

read -p "Start LiteLLM now? (y/n): " start_now

if [ "$start_now" = "y" ] || [ "$start_now" = "Y" ]; then
    echo ""
    echo -e "${BLUE}Starting LiteLLM...${NC}"
    ./start-litellm.sh
else
    echo ""
    echo "Start LiteLLM later with: ./start-litellm.sh"
fi
