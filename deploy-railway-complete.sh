#!/usr/bin/env bash

# Codebuff Complete Deployment Setup
# Railway deployment + CLI configuration with custom domain

set -e

echo "🚀 Codebuff Complete Deployment Setup"
echo "======================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}📍 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Check prerequisites
print_step "Checking prerequisites..."

# Check for Railway CLI
if ! command -v railway &> /dev/null; then
    print_error "Railway CLI is not installed"
    echo ""
    echo "Install it with:"
    echo "  npm install -g @railway/cli"
    echo "  OR"
    echo "  curl -fsSL https://railway.app/install.sh | sh"
    echo ""
    exit 1
fi
print_success "Railway CLI is installed"

# Check for Bun
if ! command -v bun &> /dev/null; then
    print_error "Bun is not installed"
    echo "Install it with: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi
print_success "Bun is installed"

# Check if logged in to Railway
if ! railway whoami &> /dev/null; then
    print_warning "Not logged in to Railway"
    echo "Please log in:"
    railway login
fi
print_success "Logged in to Railway"

echo ""
print_step "Setting up Railway project..."

# Create or link project
echo "Choose an option:"
echo "  1) Create new Railway project"
echo "  2) Link to existing Railway project"
read -p "Enter choice (1 or 2): " choice

if [ "$choice" = "1" ]; then
    railway init
    print_success "Created new Railway project"
elif [ "$choice" = "2" ]; then
    railway link
    print_success "Linked to existing Railway project"
else
    print_error "Invalid choice"
    exit 1
fi

echo ""
print_step "Adding PostgreSQL database..."
railway add --database postgres
print_success "PostgreSQL database added"

echo ""
print_step "Setting up environment variables..."

# Generate secrets
NEXTAUTH_SECRET=$(openssl rand -base64 32)
echo "Generated NEXTAUTH_SECRET: $NEXTAUTH_SECRET"

# Set essential environment variables
railway variables set NEXTAUTH_SECRET="$NEXTAUTH_SECRET"
railway variables set NEXT_PUBLIC_CB_ENVIRONMENT=prod
railway variables set NODE_ENV=production

print_success "Core environment variables set"

echo ""
print_info "You'll need to set these variables manually in Railway dashboard:"
echo ""
echo "🔑 Required API Keys:"
echo "  • OPENAI_API_KEY (or ANTHROPIC_API_KEY, CLAUDE_CODE_KEY)"
echo "  • OPEN_ROUTER_API_KEY"
echo ""
echo "🔐 Authentication:"
echo "  • CODEBUFF_GITHUB_ID (from GitHub OAuth app)"
echo "  • CODEBUFF_GITHUB_SECRET (from GitHub OAuth app)"
echo ""
echo "💳 Payment (optional):"
echo "  • STRIPE_SECRET_KEY"
echo "  • STRIPE_WEBHOOK_SECRET_KEY"
echo "  • STRIPE_USAGE_PRICE_ID"
echo "  • STRIPE_TEAM_FEE_PRICE_ID"
echo ""
echo "📧 External Services (optional):"
echo "  • LINKUP_API_KEY"
echo "  • LOOPS_API_KEY"
echo ""

read -p "Press Enter to continue with deployment..."

echo ""
print_step "Deploying to Railway..."
railway up
print_success "Application deployed!"

# Get the deployed URL
RAILWAY_URL=$(railway domain -s)
print_success "Deployed at: $RAILWAY_URL"

echo ""
print_step "Running database migrations..."
railway run bun run db:migrate
print_success "Database migrations completed"

echo ""
print_step "Setting up GitHub OAuth..."
echo ""
echo "1. Go to: https://github.com/settings/developers"
echo "2. Click 'New OAuth App'"
echo "3. Fill in:"
echo "   Application name: Codebuff (your name)"
echo "   Homepage URL: $RAILWAY_URL"
echo "   Callback URL: $RAILWAY_URL/api/auth/callback/github"
echo ""
echo "4. After creating, copy the Client ID and generate a Client Secret"
echo ""

read -p "Have you created the GitHub OAuth app? (y/n): " oauth_created

if [ "$oauth_created" = "y" ] || [ "$oauth_created" = "Y" ]; then
    read -p "Enter your GitHub Client ID: " github_id
    read -s -p "Enter your GitHub Client Secret: " github_secret
    echo ""
    
    railway variables set CODEBUFF_GITHUB_ID="$github_id"
    railway variables set CODEBUFF_GITHUB_SECRET="$github_secret"
    
    print_success "GitHub OAuth configured"
else
    print_warning "Remember to set CODEBUFF_GITHUB_ID and CODEBUFF_GITHUB_SECRET in Railway dashboard"
fi

echo ""
echo "================================================================"
echo -e "${GREEN}🎉 Railway Deployment Complete!${NC}"
echo "================================================================"
echo ""
echo "🌐 Your deployed app: $RAILWAY_URL"
echo ""
echo "📋 Next Steps:"
echo "  1. Add any remaining API keys in Railway dashboard"
echo "  2. Test your deployment by visiting the URL above"
echo "  3. Set up custom domain (see below)"
echo ""

# Custom domain setup
print_step "Custom Domain Setup"
echo ""
echo "To use your own domain with Railway:"
echo ""
echo "1. In Railway dashboard, go to Settings → Domains"
echo "2. Add your custom domain (e.g., codebuff.yourdomain.com)"
echo "3. Point your DNS to Railway's provided records:"
echo "   • CNAME record: cname.railway.app"
echo "   • OR A records to Railway's IP addresses"
echo ""
echo "4. Once DNS propagates, update environment variables:"
echo "   • NEXT_PUBLIC_CODEBUFF_APP_URL=https://yourdomain.com"
echo "   • Re-deploy with: railway up"
echo ""

echo "================================================================"
echo -e "${BLUE}📱 Codebuff CLI Configuration${NC}"
echo "================================================================"
echo ""
echo "Now configure your local CLI to use the deployed instance:"
echo ""

# Generate the CLI configuration
echo "1. Create/update CLI configuration:"
cat << EOF
# In your local .env.local, set:
NEXT_PUBLIC_CB_ENVIRONMENT=prod
NEXT_PUBLIC_CODEBUFF_APP_URL=$RAILWAY_URL
NEXT_PUBLIC_SUPPORT_EMAIL=support@yourdomain.com
NEXT_PUBLIC_POSTHOG_API_KEY=your_posthog_key
NEXT_PUBLIC_POSTHOG_HOST_URL=https://us.i.posthog.com
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=your_stripe_key
NEXT_PUBLIC_STRIPE_CUSTOMER_PORTAL=https://billing.stripe.com/p/login/test
NEXT_PUBLIC_WEB_PORT=3000

# API keys for cloud provider:
OPENAI_API_KEY=your_openai_key
OPEN_ROUTER_API_KEY=your_openrouter_key
ANTHROPIC_API_KEY=your_anthropic_key
CLAUDE_CODE_KEY=your_claude_code_key
EOF

echo ""
echo "2. Update your local CLI to use the cloud instance:"
echo "   bun --env-file=.env.local run start-cli"
echo ""

echo "3. For production use with custom domain, update:"
echo "   NEXT_PUBLIC_CODEBUFF_APP_URL=https://yourdomain.com"
echo ""

echo "================================================================"
echo -e "${PURPLE}🛠️ Useful Commands${NC}"
echo "================================================================"
echo ""
echo "Railway Commands:"
echo "  railway logs              # View deployment logs"
echo "  railway open              # Open Railway dashboard"
echo "  railway shell             # Open shell in deployment"
echo "  railway status            # Check deployment status"
echo "  railway variables list    # List all environment variables"
echo "  railway up                 # Re-deploy"
echo ""
echo "Local Development:"
echo "  make dev                   # Start local development"
echo "  make web                   # Start web server only"
echo "  make cli                   # Start CLI only"
echo "  make test                  # Run tests"
echo ""
echo "Database Management:"
echo "  make studio                # Open Drizzle Studio (local)"
echo "  railway run 'bun run db:generate'  # Generate DB schema"
echo "  railway run 'bun run db:migrate'   # Run migrations"
echo ""

echo "================================================================"
echo -e "${GREEN}🎯 Production Checklist${NC}"
echo "================================================================"
echo ""
echo "Before going live, ensure you have:"
echo ""
echo "✅ Environment Variables:"
echo "   • All API keys set in Railway dashboard"
echo "   • GitHub OAuth configured correctly"
echo "   • Custom domain pointed to Railway"
echo "   • SSL certificate (automatic with Railway)"
echo ""
echo "✅ Database:"
echo "   • Migrations applied successfully"
echo "   • Backup strategy considered"
echo ""
echo "✅ Monitoring:"
echo "   • Railway monitoring enabled"
echo "   • Error tracking set up"
echo ""
echo "✅ Security:"
echo "   • All secrets in environment variables"
echo "   • HTTPS enforced (default with Railway)"
echo "   • Rate limiting considered"
echo ""
echo "================================================================"
echo -e "${GREEN}🚀 Deployment Complete!${NC}"
echo "================================================================"
echo ""
echo "Your Codebuff instance is now deployed and ready to use!"
echo ""
echo "🌐 Production URL: $RAILWAY_URL"
echo "📚 Documentation: https://codebuff.com/docs"
echo "💬 Support: https://codebuff.com/discord"
echo ""