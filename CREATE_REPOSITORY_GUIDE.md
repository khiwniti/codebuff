# Creating a New GitHub Repository for Your Codebuff Setup

You have two options to create a new GitHub repository for your configured Codebuff:

## Option 1: Automated Script (Recommended)

Run the automated script that will guide you through the process:

```bash
./create-new-repo.sh
```

This script will:
- Ask for your GitHub username and repository name
- Help you create the repository (using GitHub CLI if available)
- Update git remotes
- Create an initial commit with all your configuration
- Push to GitHub

## Option 2: Manual Steps

### Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. Fill in the details:
   - **Repository name**: `codebuff-custom` (or your preferred name)
   - **Description**: `Codebuff AI-powered coding assistant - custom deployment`
   - **Privacy**: Choose Public or Private
   - **❗ IMPORTANT**: Do NOT initialize with README, .gitignore, or license
3. Click **"Create repository"**

### Step 2: Update Git Remote

```bash
# Remove the original Codebuff remote
git remote remove origin

# Add your new repository as origin
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Or use SSH
git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git
```

### Step 3: Configure Git (if needed)

```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Step 4: Create Initial Commit

```bash
# Stage all files
git add .

# Create commit
git commit -m "Initial commit: Codebuff configured for Railway deployment

- Installed Bun v1.3.6 and all dependencies
- Created Railway deployment configuration
- Added comprehensive deployment guides
- Created automation scripts for setup

Ready to deploy to Railway!"
```

### Step 5: Push to GitHub

```bash
# Set main as default branch
git branch -M main

# Push to GitHub
git push -u origin main
```

If you get authentication errors, see the Authentication section below.

## Authentication Options

### Option A: GitHub CLI (Easiest)

```bash
# Install GitHub CLI (if not installed)
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate
gh auth login

# Now you can push
git push -u origin main
```

### Option B: Personal Access Token

1. Create a token at https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Give it a name: `Codebuff Deployment`
4. Select scopes: `repo` (full control of private repositories)
5. Click **"Generate token"**
6. **Copy the token immediately** (you won't see it again!)

When pushing, use the token as your password:

```bash
git push -u origin main
# Username: your_github_username
# Password: paste_your_token_here
```

Or configure it in the remote URL:

```bash
git remote set-url origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Option C: SSH Key

If you have SSH keys set up:

```bash
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

If you don't have SSH keys:

1. Generate a key: `ssh-keygen -t ed25519 -C "your.email@example.com"`
2. Add to ssh-agent: `eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519`
3. Copy public key: `cat ~/.ssh/id_ed25519.pub`
4. Add to GitHub: https://github.com/settings/keys → **"New SSH key"**
5. Paste the public key and save

## Verifying Your Repository

After pushing, verify everything is uploaded:

```bash
# View your remotes
git remote -v

# Check status
git status

# View commit history
git log --oneline
```

Visit your repository on GitHub:
```
https://github.com/YOUR_USERNAME/YOUR_REPO_NAME
```

## What Gets Pushed

Your repository will include:

✅ All Codebuff source code
✅ Railway deployment configuration (`railway.json`, `nixpacks.toml`)
✅ Comprehensive deployment guides
✅ Automation scripts
✅ Environment templates
✅ `.env.local` (excluded by .gitignore - safe!)

❌ Secrets and credentials (protected by .gitignore)
❌ node_modules (excluded)
❌ Build artifacts (excluded)

## Next Steps After Creating Repository

1. **Star the original Codebuff repository** to show support
   - https://github.com/CodebuffAI/codebuff

2. **Connect Repository to Railway**
   - Go to Railway dashboard
   - Create new project
   - Connect to GitHub
   - Select your repository
   - Railway will auto-deploy!

3. **Set up GitHub OAuth**
   - Follow `GITHUB_OAUTH_SETUP.md`
   - Use your repository URL in callback: `https://your-app.railway.app/api/auth/callback/github`

4. **Configure environment variables**
   - Use Railway dashboard or `./setup-railway-env.sh`
   - See `.env.railway.template` for all variables

## Troubleshooting

### "Repository already exists"
If the repository name is taken, choose a different name.

### "Permission denied"
Check your authentication (token, SSH key, or GitHub CLI).

### "Nothing to commit"
You may have already committed. Try `git push -u origin main` directly.

### "Remote already exists"
Remove it first: `git remote remove origin`

### "Authentication failed"
- Verify your token/password is correct
- Check if token has `repo` scope
- Try using GitHub CLI: `gh auth login`

## Need Help?

- **GitHub Docs**: https://docs.github.com/en/get-started/quickstart/create-a-repo
- **SSH Key Setup**: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- **Personal Access Tokens**: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

---

**Quick Command Reference**

```bash
# Create repo with script
./create-new-repo.sh

# Or manual steps
git remote remove origin
git remote add origin https://github.com/USERNAME/REPO.git
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

Good luck! 🚀
