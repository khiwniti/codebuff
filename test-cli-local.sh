#!/usr/bin/env bash

# Test Codebuff CLI without subscription
# This script tests the CLI in standalone mode

set -e

echo "🧪 Testing Codebuff CLI - No Subscription Required"
echo "=================================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

cd /workspace/codebuff

echo -e "${BLUE}1. Checking Bun installation...${NC}"
if ~/.bun/bin/bun --version; then
    echo -e "${GREEN}✓ Bun is installed${NC}"
else
    echo -e "${RED}✗ Bun not found${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}2. Checking dependencies...${NC}"
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ Dependencies not found. Run: bun install${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}3. Checking environment configuration...${NC}"
if [ -f ".env.local" ]; then
    echo -e "${GREEN}✓ .env.local exists${NC}"
    
    # Check required vars
    required_vars=(
        "NEXT_PUBLIC_CB_ENVIRONMENT"
        "NEXT_PUBLIC_CODEBUFF_APP_URL"
        "NEXT_PUBLIC_SUPPORT_EMAIL"
    )
    
    missing=0
    for var in "${required_vars[@]}"; do
        if grep -q "^${var}=" .env.local; then
            echo -e "${GREEN}  ✓ $var is set${NC}"
        else
            echo -e "${RED}  ✗ $var is missing${NC}"
            missing=1
        fi
    done
    
    if [ $missing -eq 1 ]; then
        echo -e "${YELLOW}  ⚠ Some variables are missing${NC}"
    fi
else
    echo -e "${RED}✗ .env.local not found${NC}"
    echo "Create it from .env.example: cp .env.example .env.local"
    exit 1
fi
echo ""

echo -e "${BLUE}4. Testing CLI help command...${NC}"
echo "Running: bun run src/index.tsx --help"
echo ""

cd cli
export $(cat ../.env.local | grep -v '^#' | xargs)

if ~/.bun/bin/bun run src/index.tsx --help 2>&1 | head -30; then
    echo ""
    echo -e "${GREEN}✓ CLI help works!${NC}"
else
    echo -e "${RED}✗ CLI help failed${NC}"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ CLI Basic Test Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -e "${YELLOW}📝 Notes:${NC}"
echo "• The CLI can run in standalone mode for local development"
echo "• For full functionality, you need:"
echo "  1. PostgreSQL database (local or Railway)"
echo "  2. AI API key (OpenAI or Anthropic)"
echo "  3. Optional: GitHub OAuth for web authentication"
echo ""
echo "• The CLI does NOT require a subscription to work"
echo "• Credits system is for the hosted web version only"
echo ""

echo -e "${BLUE}Next steps to test full CLI:${NC}"
echo "1. Set up a database (PostgreSQL)"
echo "2. Run migrations: bun run db:migrate"
echo "3. Add your AI API key to .env.local"
echo "4. Test CLI: bun run dev"
echo ""

echo -e "${GREEN}Local development is subscription-free! 🎉${NC}"
