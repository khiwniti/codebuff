#!/usr/bin/env bash

# Script to Create New GitHub Repository for Codebuff
# This script helps you create a new GitHub repository and push your configured Codebuff

set -e

echo "🆕 Create New GitHub Repository for Codebuff"
echo "============================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}This script will help you create a new GitHub repository and push your configured Codebuff.${NC}"
echo ""

# Get repository details
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " REPOSITORY DETAILS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Enter your GitHub username: " github_username
read -p "Enter repository name (e.g., codebuff-custom): " repo_name
read -p "Make repository private? (y/n, default: n): " is_private
read -p "Repository description (optional): " repo_description

if [ -z "$repo_description" ]; then
    repo_description="Codebuff AI-powered coding assistant - custom deployment"
fi

if [ "$is_private" = "y" ] || [ "$is_private" = "Y" ]; then
    privacy="true"
else
    privacy="false"
fi

echo ""
echo -e "${YELLOW}Repository will be created with:${NC}"
echo "  Username: $github_username"
echo "  Repository: $repo_name"
echo "  Private: $privacy"
echo "  Description: $repo_description"
echo ""

read -p "Continue? (y/n): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " CREATING REPOSITORY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if GitHub CLI is installed
if command -v gh &> /dev/null; then
    echo -e "${GREEN}Using GitHub CLI (gh)...${NC}"
    
    # Create repository using GitHub CLI
    if [ "$privacy" = "true" ]; then
        gh repo create "$github_username/$repo_name" --private --description "$repo_description" --source=. --remote=origin-new || {
            echo -e "${YELLOW}Note: If you get an authentication error, run: gh auth login${NC}"
            exit 1
        }
    else
        gh repo create "$github_username/$repo_name" --public --description "$repo_description" --source=. --remote=origin-new || {
            echo -e "${YELLOW}Note: If you get an authentication error, run: gh auth login${NC}"
            exit 1
        }
    fi
    
    echo -e "${GREEN}✓ Repository created successfully!${NC}"
    
else
    echo -e "${YELLOW}GitHub CLI (gh) not found.${NC}"
    echo ""
    echo "Please create the repository manually:"
    echo ""
    echo "1. Go to: https://github.com/new"
    echo "2. Repository name: $repo_name"
    echo "3. Description: $repo_description"
    echo "4. Privacy: $([ "$privacy" = "true" ] && echo "Private" || echo "Public")"
    echo "5. Do NOT initialize with README, .gitignore, or license"
    echo "6. Click 'Create repository'"
    echo ""
    read -p "Press Enter after creating the repository..."
    
    # Add remote manually
    echo ""
    echo "Adding remote..."
    git remote add origin-new "https://github.com/$github_username/$repo_name.git" || {
        echo -e "${RED}Failed to add remote. It may already exist.${NC}"
        echo "Try: git remote remove origin-new"
        exit 1
    }
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " PREPARING TO PUSH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Remove original origin and rename new remote
echo "Updating remotes..."
git remote remove origin
git remote rename origin-new origin

echo -e "${GREEN}✓ Remote updated${NC}"
echo ""

# Check git config
if ! git config user.name &> /dev/null; then
    echo "Setting up git config..."
    git config user.name "$github_username"
    git config user.email "$github_username@users.noreply.github.com"
fi

# Create a commit with all the setup files
echo "Creating commit with your configuration..."
git add .
git commit -m "Initial commit: Codebuff configured for Railway deployment

- Installed Bun v1.3.6 and all dependencies
- Created Railway deployment configuration (railway.json, nixpacks.toml)
- Added comprehensive deployment guides
- Created automation scripts for setup
- Configured environment templates

Setup includes:
- RAILWAY_DEPLOYMENT_GUIDE.md - Complete Railway deployment instructions
- GITHUB_OAUTH_SETUP.md - GitHub OAuth configuration guide
- SETUP_COMPLETE.md - Setup overview and next steps
- QUICK_REFERENCE.md - Quick command reference
- Automation scripts for Railway setup

Ready to deploy to Railway!
" || echo "Nothing to commit or already committed"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " PUSHING TO GITHUB"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Push to GitHub
echo "Pushing to GitHub..."
git branch -M main
git push -u origin main || {
    echo ""
    echo -e "${RED}Push failed!${NC}"
    echo ""
    echo "This is likely due to authentication. Try one of these:"
    echo ""
    echo "Option 1: Use GitHub CLI"
    echo "  gh auth login"
    echo "  git push -u origin main"
    echo ""
    echo "Option 2: Use Personal Access Token"
    echo "  1. Create token at: https://github.com/settings/tokens"
    echo "  2. Use it as password when prompted"
    echo ""
    echo "Option 3: Use SSH"
    echo "  git remote set-url origin git@github.com:$github_username/$repo_name.git"
    echo "  git push -u origin main"
    echo ""
    exit 1
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Repository Created Successfully!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔗 Your repository:"
echo "   https://github.com/$github_username/$repo_name"
echo ""

echo "📋 Next steps:"
echo "   1. View your repository online"
echo "   2. Follow RAILWAY_DEPLOYMENT_GUIDE.md to deploy"
echo "   3. Set up GitHub OAuth (GITHUB_OAUTH_SETUP.md)"
echo "   4. Deploy to Railway!"
echo ""

echo -e "${BLUE}Happy coding! 🚀${NC}"
