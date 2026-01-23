#!/usr/bin/env bash

# Codebuff Railway Setup Script
# This script helps automate the Railway deployment setup

set -e

echo "🚂 Codebuff Railway Setup Script"
echo "================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo -e "${RED}❌ Railway CLI is not installed${NC}"
    echo ""
    echo "Install it with one of these methods:"
    echo "  npm install -g @railway/cli"
    echo "  OR"
    echo "  curl -fsSL https://railway.app/install.sh | sh"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Railway CLI is installed${NC}"

# Check if user is logged in
if ! railway whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Railway${NC}"
    echo "Please log in:"
    railway login
fi

echo -e "${GREEN}✅ Logged in to Railway${NC}"
echo ""

# Ask if user wants to create a new project or link existing
echo "Do you want to:"
echo "  1) Create a new Railway project"
echo "  2) Link to an existing Railway project"
read -p "Enter choice (1 or 2): " choice

if [ "$choice" = "1" ]; then
    echo ""
    echo -e "${BLUE}Creating new Railway project...${NC}"
    railway init
elif [ "$choice" = "2" ]; then
    echo ""
    echo -e "${BLUE}Linking to existing Railway project...${NC}"
    railway link
else
    echo -e "${RED}Invalid choice${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Railway project configured${NC}"
echo ""

# Ask if user wants to add PostgreSQL
read -p "Do you want to add PostgreSQL database? (y/n): " add_db

if [ "$add_db" = "y" ] || [ "$add_db" = "Y" ]; then
    echo ""
    echo -e "${BLUE}Adding PostgreSQL database...${NC}"
    railway add --database postgres
    echo -e "${GREEN}✅ PostgreSQL database added${NC}"
    echo "   DATABASE_URL environment variable has been automatically set"
fi

echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "1. Set up GitHub OAuth Application:"
echo "   • Go to https://github.com/settings/developers"
echo "   • Create a new OAuth App"
echo "   • Set callback URL to: https://your-app.railway.app/api/auth/callback/github"
echo ""

echo "2. Set environment variables in Railway:"
echo "   Review .env.railway.template for required variables"
echo ""
echo "   Required variables:"
echo "   • CODEBUFF_GITHUB_ID"
echo "   • CODEBUFF_GITHUB_SECRET"
echo "   • NEXTAUTH_SECRET (generate with: openssl rand -base64 32)"
echo "   • OPENAI_API_KEY or ANTHROPIC_API_KEY"
echo "   • NEXT_PUBLIC_CODEBUFF_APP_URL"
echo ""

echo "   Set variables with:"
echo "   ${BLUE}railway variables set KEY=value${NC}"
echo ""

echo "3. Generate NEXTAUTH_SECRET:"
echo "   ${BLUE}openssl rand -base64 32${NC}"
openssl rand -base64 32
echo ""

echo "4. Deploy to Railway:"
echo "   ${BLUE}railway up${NC}"
echo ""
echo "   Or connect GitHub repository for automatic deployments"
echo "   (do this in Railway dashboard)"
echo ""

echo "5. After deployment, run database migrations:"
echo "   ${BLUE}railway run bun run db:migrate${NC}"
echo ""

echo "6. Update GitHub OAuth callback URL with your actual Railway URL"
echo ""

echo "7. Give yourself credits (see RAILWAY_DEPLOYMENT_GUIDE.md for details)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}For detailed instructions, see:${NC}"
echo "  📖 RAILWAY_DEPLOYMENT_GUIDE.md"
echo ""
echo -e "${GREEN}Useful commands:${NC}"
echo "  railway logs       - View logs"
echo "  railway open       - Open dashboard"
echo "  railway shell      - Open shell"
echo "  railway status     - View status"
echo ""
echo -e "${BLUE}Good luck with your deployment! 🚀${NC}"
