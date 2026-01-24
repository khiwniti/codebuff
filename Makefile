# Codebuff Development Makefile
# Usage: make [command]

# Ensure Bun is available
export PATH := $(HOME)/.bun/bin:$(PATH)

.PHONY: help install dev web cli test typecheck format clean build

# Default target
help:
	@echo "🚀 Codebuff Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  install       Install all dependencies"
	@echo "  dev          Start all services (web + CLI)"
	@echo "  setup        Full setup for new contributors"
	@echo "  quick        Install + dev (one-click setup)"
	@echo ""
	@echo "Individual Services:"
	@echo "  web          Start web server only"
	@echo "  cli          Start CLI only"
	@echo "  db           Start database only"
	@echo "  studio       Open Drizzle Studio (DB GUI)"
	@echo ""
	@echo "Development:"
	@echo "  test         Run all tests"
	@echo "  typecheck    Type check all packages"
	@echo "  format       Format all files with Prettier"
	@echo "  clean        Clean dependencies and build artifacts"
	@echo "  watch        Run format + typecheck + test"
	@echo ""
	@echo "Health & Troubleshooting:"
	@echo "  health       Check service health"
	@echo "  troubleshoot Fix browser connection issues"
	@echo ""
	@echo "Build:"
	@echo "  build        Build all packages"
	@echo "  build-web    Build web package"
	@echo "  build-sdk    Build SDK package"
	@echo ""
	@echo "Deployment (Railway):"
	@echo "  deploy-setup   Complete Railway setup wizard"
	@echo "  deploy        Deploy to Railway"
	@echo "  deploy-logs   View Railway logs"
	@echo "  deploy-shell   Open Railway shell"
	@echo "  deploy-status  Check Railway status"
	@echo "  deploy-vars    List Railway variables"
	@echo "  domain-setup  Guide for custom domain setup"
	@echo "  cli-cloud     Configure CLI for cloud usage"
	@echo ""
	@echo "Utilities:"
	@echo "  publish      Publish base agents to database"
	@echo "  status       Check service status"
	@echo "  up           Alias for dev"
	@echo "  down         Stop all services"
	@echo "  restart      Restart all services"

# Setup commands
install:
	@echo "📦 Installing dependencies..."
	bun install

dev:
	@echo "🚀 Starting all services..."
	bun --env-file=.env.local run dev

web:
	@echo "🌐 Starting web server..."
	bun --env-file=.env.local run start-web

cli:
	@echo "💻 Starting CLI..."
	bun --env-file=.env.local run start-cli

db:
	@echo "🗄️ Starting database..."
	bun --env-file=.env.local run start-db

studio:
	@echo "🎨 Opening Drizzle Studio..."
	bun --env-file=.env.local run start-studio

# Development commands
test:
	@echo "🧪 Running tests..."
	bun test

typecheck:
	@echo "🔍 Type checking..."
	bun run typecheck

format:
	@echo "✨ Formatting code..."
	bun run format

clean:
	@echo "🧹 Cleaning up..."
	rm -rf node_modules
	rm -rf bun.lock
	rm -rf .next
	rm -rf dist
	bun install

# Build commands
build:
	@echo "🏗️ Building all packages..."
	bun run build

build-web:
	@echo "🏗️ Building web package..."
	cd web && bun run build

build-sdk:
	@echo "🏗️ Building SDK package..."
	cd sdk && bun run release

# Utility commands
publish:
	@echo "📤 Publishing base agents..."
	bun --env-file=.env.local run start-cli publish base context-pruner file-explorer file-picker researcher thinker reviewer

status:
	@echo "📊 Checking service status..."
	bun --env-file=.env.local run ps

# Deployment commands
deploy-setup:
	@echo "🚀 Setting up Railway deployment..."
	./deploy-railway-complete.sh

deploy:
	@echo "🚂 Deploying to Railway..."
	railway up

deploy-logs:
	@echo "📋 Viewing Railway logs..."
	railway logs --tail

deploy-shell:
	@echo "🐚 Opening Railway shell..."
	railway shell

deploy-status:
	@echo "📊 Checking Railway status..."
	railway status

deploy-vars:
	@echo "🔧 Listing Railway variables..."
	railway variables list

# Custom domain setup
domain-setup:
	@echo "🌐 Setting up custom domain..."
	@echo "1. In Railway dashboard, go to Settings → Domains"
	@echo "2. Add your custom domain (e.g., codebuff.yourdomain.com)"
	@echo "3. Update your DNS records as shown in Railway"
	@echo "4. Update environment variables:"
	@echo "   NEXT_PUBLIC_CODEBUFF_APP_URL=https://yourdomain.com"
	@echo "5. Re-deploy with: make deploy"

# CLI configuration for cloud
cli-cloud:
	@echo "📱 Configuring CLI for cloud usage..."
	@echo "Set these in your .env.local:"
	@echo "NEXT_PUBLIC_CB_ENVIRONMENT=prod"
	@echo "NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-railway-url.railway.app"
	@read -p "Enter your Railway URL: " railway_url && \
	echo "NEXT_PUBLIC_CODEBUFF_APP_URL=$$railway_url" >> .env.cloud
	@echo "Created .env.cloud file. Use: bun --env-file=.env.cloud run start-cli"

# Quick development workflow
quick: install dev
	@echo "⚡ Quick start complete!"

# Full setup for new contributors
setup: install
	@echo "🎉 Setting up Codebuff for development..."
	@echo "✅ Dependencies installed"
	@echo "📝 Next steps:"
	@echo "   1. Run 'make dev' to start all services"
	@echo "   2. Open http://localhost:4242 for the web app"
	@echo "   3. Check 'make help' for more commands"

# Quick reference shortcuts
up: dev
down:
	@echo "🛑 Stopping services..."
	docker compose -f packages/internal/src/db/docker-compose.yml down
restart: down web
	@echo "🔄 Services restarted"

# Common development workflow
watch: format typecheck test
	@echo "👀 Development checks complete"

# Troubleshooting
troubleshoot:
	@echo "🔧 CLI Browser Connection Troubleshooting"
	@echo "=========================================="
	@echo ""
	@echo "🚨 Issue: 'Unable to connect browser' when trying to login"
	@echo ""
	@echo "🛠️ Quick Fix:"
	@echo "1. Start web server first: make web"
	@echo "2. Then start CLI: make cli"
	@echo "3. Try login again"
	@echo ""
	@echo "🔍 Check web server:"
	@echo "curl http://localhost:4242/api/healthz"
	@echo ""
	@echo "📖 Full guide: CLI_TROUBLESHOOTING.md"

# Health check
health:
	@echo "🏥 Checking Codebuff services health..."
	@echo ""
	@echo "📊 Web Server:"
	@if curl -s http://localhost:4242/api/healthz > /dev/null; then \
		echo "✅ Web server: RUNNING (http://localhost:4242)"; \
	else \
		echo "❌ Web server: NOT RUNNING"; \
	fi
	@echo ""
	@echo "🗄️ Database:"
	@if docker ps | grep -q "manicode-db-1"; then \
		echo "✅ Database: RUNNING"; \
	else \
		echo "❌ Database: NOT RUNNING"; \
	fi
	@echo ""
	@echo "📱 CLI Environment:"
	@if [ -f .env.local ]; then \
		echo "✅ Environment file: EXISTS"; \
		grep NEXT_PUBLIC_CODEBUFF_APP_URL .env.local || echo "⚠️  NEXT_PUBLIC_CODEBUFF_APP_URL not set"; \
	else \
		echo "❌ Environment file: MISSING"; \
	fi