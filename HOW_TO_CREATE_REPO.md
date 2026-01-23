# 📦 Create Your Own Codebuff Repository

Your Codebuff setup is ready to be pushed to a new GitHub repository!

## 🚀 Quick Start

### Easiest Way: Run the Automation Script

```bash
./create-new-repo.sh
```

This interactive script will:
1. Ask for your GitHub username and repository name
2. Create the repository (using GitHub CLI if available)
3. Update git remotes
4. Create initial commit with all your configuration
5. Push to GitHub

### Manual Way: Step-by-Step

If you prefer to do it manually or if the script doesn't work, see:
- **CREATE_REPOSITORY_GUIDE.md** - Complete manual instructions

## 📋 What You Need

Before creating the repository:

1. **GitHub Account** - https://github.com
2. **Authentication** - One of:
   - GitHub CLI (`gh auth login`) - Easiest
   - Personal Access Token - https://github.com/settings/tokens
   - SSH Key - https://github.com/settings/keys

## ✅ What Will Be Included

Your new repository will contain:

### Configuration Files
- ✅ `railway.json` - Railway deployment config
- ✅ `nixpacks.toml` - Build configuration
- ✅ `.env.railway.template` - Environment variables reference
- ✅ `.env.local` - **Excluded by .gitignore** (safe!)

### Documentation
- ✅ `RAILWAY_DEPLOYMENT_GUIDE.md` - Railway deployment instructions
- ✅ `GITHUB_OAUTH_SETUP.md` - GitHub OAuth setup guide
- ✅ `SETUP_COMPLETE.md` - Setup overview
- ✅ `QUICK_REFERENCE.md` - Quick commands reference
- ✅ `CREATE_REPOSITORY_GUIDE.md` - This guide for creating repos

### Automation Scripts
- ✅ `setup-railway.sh` - Railway project setup
- ✅ `setup-railway-env.sh` - Environment variables setup
- ✅ `create-new-repo.sh` - Repository creation helper

### Source Code
- ✅ All Codebuff source code (web, cli, sdk, agents, etc.)
- ✅ Dependencies installed (node_modules excluded from git)
- ✅ All original documentation and guides

## 🔒 Security

Don't worry about secrets being exposed:

- ❌ `.env.local` is **excluded** by `.gitignore`
- ❌ `node_modules/` is **excluded**
- ❌ Build artifacts are **excluded**
- ✅ Only safe configuration files are included

## 📝 Repository Name Suggestions

Choose a descriptive name:
- `codebuff-custom`
- `codebuff-deployment`
- `my-codebuff`
- `codebuff-railway`
- `codebuff-instance`

## 🎯 Next Steps After Creating Repository

1. **Your repository is created** ✅
   - View it at: `https://github.com/YOUR_USERNAME/YOUR_REPO`

2. **Connect to Railway** (see RAILWAY_DEPLOYMENT_GUIDE.md)
   ```bash
   railway login
   railway init  # or link existing project
   # Connect your GitHub repo in Railway dashboard
   ```

3. **Set up GitHub OAuth** (see GITHUB_OAUTH_SETUP.md)
   - Create OAuth app at: https://github.com/settings/developers
   - Use callback: `https://your-app.railway.app/api/auth/callback/github`

4. **Deploy to Railway**
   ```bash
   ./setup-railway-env.sh  # Set environment variables
   # Railway will auto-deploy from GitHub!
   ```

## 💡 Pro Tips

1. **Make it private initially** - You can make it public later
2. **Add a custom README** - Document your specific setup
3. **Enable GitHub Actions** - For CI/CD (optional)
4. **Star the original** - Show support: https://github.com/CodebuffAI/codebuff
5. **Keep in sync** - You can merge updates from original repo later

## 🔄 Keeping Updated from Original

If you want to pull updates from the original Codebuff repository later:

```bash
# Add original repo as upstream
git remote add upstream https://github.com/CodebuffAI/codebuff.git

# Fetch updates
git fetch upstream

# Merge updates (when you want to update)
git merge upstream/main

# Push to your repo
git push origin main
```

## 🐛 Troubleshooting

### Script Fails

If `./create-new-repo.sh` fails, follow the manual steps in `CREATE_REPOSITORY_GUIDE.md`

### Authentication Issues

Try these in order:
1. **GitHub CLI**: `gh auth login`
2. **Personal Access Token**: Create at https://github.com/settings/tokens
3. **SSH Key**: Set up at https://github.com/settings/keys

### Repository Name Already Exists

Choose a different name or delete the existing repository first.

### Can't Push

Make sure you have write access to the repository and authentication is working.

## 📚 Documentation Reference

| File | Purpose |
|------|---------|
| **CREATE_REPOSITORY_GUIDE.md** | Manual repository creation |
| **RAILWAY_DEPLOYMENT_GUIDE.md** | Deploy to Railway |
| **GITHUB_OAUTH_SETUP.md** | OAuth configuration |
| **SETUP_COMPLETE.md** | Overall setup guide |
| **QUICK_REFERENCE.md** | Quick commands |

## 🎬 Full Workflow Example

```bash
# 1. Create repository
./create-new-repo.sh
# Enter your GitHub username: myusername
# Enter repository name: codebuff-custom
# (Follow prompts)

# 2. Set up Railway
railway login
railway init
railway add postgres

# 3. Configure environment
./setup-railway-env.sh

# 4. Connect GitHub repo in Railway dashboard
# Go to Railway → Your Project → Settings → Connect Repo

# 5. Railway auto-deploys!
# Check: railway logs -f

# 6. Done! 🎉
```

## 🔗 Quick Links

- **Create new GitHub repo**: https://github.com/new
- **GitHub tokens**: https://github.com/settings/tokens
- **SSH keys**: https://github.com/settings/keys
- **Railway dashboard**: https://railway.app
- **Original Codebuff**: https://github.com/CodebuffAI/codebuff

---

## ⚡ TL;DR - Create Repo in 30 Seconds

```bash
./create-new-repo.sh
```

Follow the prompts, and you're done!

**Need help?** See `CREATE_REPOSITORY_GUIDE.md` for detailed instructions.

---

**Ready to create your repository? Run:**

```bash
./create-new-repo.sh
```

**Good luck! 🚀**
