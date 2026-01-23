#!/usr/bin/env bash

# Quick Railway Environment Variables Setup
# This script helps you set all required environment variables in Railway

set -e

echo "🔐 Codebuff Railway Environment Variables Setup"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo -e "${RED}❌ Railway CLI is not installed${NC}"
    echo "Install it first: npm install -g @railway/cli"
    exit 1
fi

# Check if logged in
if ! railway whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Railway${NC}"
    railway login
fi

echo -e "${BLUE}This script will help you set all required environment variables.${NC}"
echo ""
echo -e "${YELLOW}Note: You can skip optional variables by pressing Enter${NC}"
echo ""

# Function to set variable
set_variable() {
    local var_name=$1
    local var_description=$2
    local is_required=$3
    local is_secret=$4
    
    if [ "$is_required" = "true" ]; then
        echo -e "${GREEN}✱ Required${NC}: $var_description"
    else
        echo -e "${BLUE}Optional${NC}: $var_description"
    fi
    
    if [ "$is_secret" = "true" ]; then
        read -sp "Enter $var_name (input hidden): " var_value
        echo ""
    else
        read -p "Enter $var_name: " var_value
    fi
    
    if [ -n "$var_value" ]; then
        railway variables set "$var_name=$var_value"
        echo -e "${GREEN}✓ Set $var_name${NC}"
    elif [ "$is_required" = "true" ]; then
        echo -e "${RED}✗ $var_name is required!${NC}"
        return 1
    else
        echo -e "${YELLOW}○ Skipped $var_name${NC}"
    fi
    echo ""
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " AUTHENTICATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

set_variable "CODEBUFF_GITHUB_ID" "GitHub OAuth Client ID" true false
set_variable "CODEBUFF_GITHUB_SECRET" "GitHub OAuth Client Secret" true true

# Generate NextAuth secret
echo -e "${GREEN}Generating NEXTAUTH_SECRET...${NC}"
nextauth_secret=$(openssl rand -base64 32)
railway variables set "NEXTAUTH_SECRET=$nextauth_secret"
echo -e "${GREEN}✓ Set NEXTAUTH_SECRET (auto-generated)${NC}"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " AI API KEYS (at least one required)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

set_variable "OPENAI_API_KEY" "OpenAI API Key (starts with sk-)" false true
set_variable "ANTHROPIC_API_KEY" "Anthropic API Key (starts with sk-ant-)" false true
set_variable "CLAUDE_CODE_KEY" "Claude Code API Key" false true
set_variable "OPEN_ROUTER_API_KEY" "OpenRouter API Key" false true

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " APPLICATION CONFIGURATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Set default PORT
railway variables set "PORT=3000"
echo -e "${GREEN}✓ Set PORT=3000${NC}"
echo ""

# Set NODE_ENV
railway variables set "NODE_ENV=production"
echo -e "${GREEN}✓ Set NODE_ENV=production${NC}"
echo ""

# Set CB_ENVIRONMENT
railway variables set "NEXT_PUBLIC_CB_ENVIRONMENT=production"
echo -e "${GREEN}✓ Set NEXT_PUBLIC_CB_ENVIRONMENT=production${NC}"
echo ""

set_variable "NEXT_PUBLIC_CODEBUFF_APP_URL" "Your Railway app URL (e.g., https://your-app.railway.app)" true false
set_variable "NEXT_PUBLIC_SUPPORT_EMAIL" "Support email address" true false

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " OPTIONAL: STRIPE PAYMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Do you want to configure Stripe? (y/n): " configure_stripe

if [ "$configure_stripe" = "y" ] || [ "$configure_stripe" = "Y" ]; then
    set_variable "STRIPE_SECRET_KEY" "Stripe Secret Key" false true
    set_variable "STRIPE_WEBHOOK_SECRET_KEY" "Stripe Webhook Secret" false true
    set_variable "STRIPE_USAGE_PRICE_ID" "Stripe Usage Price ID" false false
    set_variable "STRIPE_TEAM_FEE_PRICE_ID" "Stripe Team Fee Price ID" false false
    set_variable "NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY" "Stripe Publishable Key" false false
    set_variable "NEXT_PUBLIC_STRIPE_CUSTOMER_PORTAL" "Stripe Customer Portal URL" false false
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " OPTIONAL: EXTERNAL SERVICES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Do you want to configure external services? (y/n): " configure_services

if [ "$configure_services" = "y" ] || [ "$configure_services" = "Y" ]; then
    set_variable "LINKUP_API_KEY" "Linkup API Key" false true
    set_variable "LOOPS_API_KEY" "Loops API Key" false true
    set_variable "NEXT_PUBLIC_POSTHOG_API_KEY" "PostHog API Key" false true
    set_variable "NEXT_PUBLIC_POSTHOG_HOST_URL" "PostHog Host URL (default: https://us.i.posthog.com)" false false
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " OPTIONAL: DISCORD INTEGRATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Do you want to configure Discord integration? (y/n): " configure_discord

if [ "$configure_discord" = "y" ] || [ "$configure_discord" = "Y" ]; then
    set_variable "DISCORD_PUBLIC_KEY" "Discord Public Key" false false
    set_variable "DISCORD_BOT_TOKEN" "Discord Bot Token" false true
    set_variable "DISCORD_APPLICATION_ID" "Discord Application ID" false false
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Environment variables setup complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📋 Summary:"
echo "• View all variables: ${BLUE}railway variables${NC}"
echo "• Deploy application: ${BLUE}railway up${NC}"
echo "• View logs: ${BLUE}railway logs -f${NC}"
echo "• Open dashboard: ${BLUE}railway open${NC}"
echo ""

echo "⚠️  Important Notes:"
echo "• DATABASE_URL is automatically set when you add PostgreSQL"
echo "• After deployment, run migrations: ${BLUE}railway run bun run db:migrate${NC}"
echo "• Update GitHub OAuth callback URL with your actual Railway URL"
echo "• Give yourself credits after first login (see RAILWAY_DEPLOYMENT_GUIDE.md)"
echo ""

echo -e "${GREEN}Ready to deploy! 🚀${NC}"
