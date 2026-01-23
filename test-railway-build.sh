#!/usr/bin/env bash
# Test Railway build process locally before deploying
set -e

echo "========================================"
echo "Testing Railway Build Process Locally"
echo "========================================"
echo ""

# Export required environment variables for build
export NEXT_PUBLIC_CB_ENVIRONMENT="prod"
export NEXT_PUBLIC_CODEBUFF_APP_URL="https://your-app.railway.app"
export NEXT_PUBLIC_SUPPORT_EMAIL="support@codebuff.com"
export NEXT_PUBLIC_POSTHOG_API_KEY="phc_test_key"
export NEXT_PUBLIC_POSTHOG_HOST_URL="https://us.i.posthog.com"
export NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_test_dummy"
export NEXT_PUBLIC_STRIPE_CUSTOMER_PORTAL="https://billing.stripe.com/p/login/test"
export NEXT_PUBLIC_WEB_PORT="3000"

# Server-side environment variables (Railway will have these set)
export OPEN_ROUTER_API_KEY="dummy_key"
export OPENAI_API_KEY="dummy_key"
export ANTHROPIC_API_KEY="dummy_key"
export LINKUP_API_KEY="dummy_key"
export GRAVITY_API_KEY="dummy_key"
export PORT="3000"
export DATABASE_URL="postgresql://user:pass@localhost:5432/db"
export CODEBUFF_GITHUB_ID="dummy_id"
export CODEBUFF_GITHUB_SECRET="dummy_secret"
export NEXTAUTH_SECRET="dummy_nextauth_secret_min_32_chars_long"
export STRIPE_SECRET_KEY="sk_test_dummy"
export STRIPE_WEBHOOK_SECRET_KEY="whsec_dummy"
export STRIPE_USAGE_PRICE_ID="price_dummy"
export STRIPE_TEAM_FEE_PRICE_ID="price_dummy"

echo "Step 1: Installing dependencies..."
bun install

echo ""
echo "Step 2: Building web app..."
bun --cwd web run build

echo ""
echo "========================================"
echo "✅ Build test successful!"
echo "========================================"
echo ""
echo "The Railway deployment should work with the same build command."
echo ""
echo "Next steps:"
echo "1. Ensure all NEXT_PUBLIC_* environment variables are set in Railway"
echo "2. Deploy using: railway up"
echo ""
