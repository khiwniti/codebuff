# 🔧 CLI Browser Connection Troubleshooting Guide

## 🚨 Issue: "Unable to connect browser" when trying to login

This error occurs when the CLI tries to open a browser for authentication but can't connect to the web server.

## 🛠️ Quick Fix

### 1. Start the Web Server First

```bash
# Start web server (required for CLI authentication)
make web

# Or start both services together
make dev
```

### 2. Then Start CLI

```bash
# In a separate terminal
make cli
```

### 3. Try Login Again

- Press Enter when prompted
- Browser should open to http://localhost:4242

## 🔍 Detailed Troubleshooting

### Check Web Server Status

```bash
# Check if web server is running
curl http://localhost:4242/api/healthz

# Expected response: {"status":"ok"}
```

### Check Environment Variables

```bash
# Check if CLI is pointing to correct URL
cat .env.local | grep NEXT_PUBLIC_CODEBUFF_APP_URL

# Should be: http://localhost:4242 (for development)
```

### Check Port Conflicts

```bash
# Check what's running on port 4242
lsof -i :4242

# Or check all ports
netstat -tulpn | grep :4242
```

## 🚀 Complete Workflow

### Option 1: Automated (Recommended)

```bash
# Start everything automatically
make dev

# CLI will connect to running web server
```

### Option 2: Manual Control

```bash
# Terminal 1: Start web server
make web

# Terminal 2: Start CLI
make cli

# Terminal 3: (Optional) Database tools
make studio
```

### Option 3: Development Mode

```bash
# Use the setup script
./start-dev.sh
```

## 🔧 Common Issues and Solutions

### Issue 1: Web Server Won't Start

```bash
# Clean and restart
make down
make web

# Check Docker status
docker ps
```

### Issue 2: Database Connection Error

```bash
# Restart database
make down
make db
make web
```

### Issue 3: Port Already in Use

```bash
# Kill process on port 4242
sudo kill -9 $(lsof -t -i:4242)

# Then restart
make web
```

### Issue 4: Environment Variable Issues

```bash
# Reset environment
cp .env.example .env.local
make setup
make dev
```

### Issue 5: Browser Won't Open

```bash
# Manual login - copy URL from CLI
# Open manually in browser: http://localhost:4242/login
```

## 🌐 Alternative Login Methods

### Method 1: Manual URL

1. Start CLI with `make cli`
2. When prompted, copy the login URL
3. Paste manually in browser
4. Complete authentication
5. Return to CLI

### Method 2: API Key (Advanced)

```bash
# Set API key directly
export CODEBUFF_API_KEY=your_api_key_here

# Then start CLI
make cli
```

### Method 3: Direct Web Login

1. Open http://localhost:4242/login
2. Login via web interface
3. CLI will authenticate automatically

## 📱 Testing the Fix

### Test 1: Health Check

```bash
curl http://localhost:4242/api/healthz
# Should return: {"status":"ok"}
```

### Test 2: Web Interface

```bash
# Open in browser
http://localhost:4242
# Should load the Codebuff interface
```

### Test 3: CLI Connection

```bash
make cli
# Should show "Connected to server" message
```

## 🔄 Reset Everything

If nothing works, reset the entire development environment:

```bash
# Complete reset
make down
make clean
make setup
make dev
```

## 📞 Get Help

- **Documentation**: [CLI_DEPLOYMENT_GUIDE.md](./CLI_DEPLOYMENT_GUIDE.md)
- **Quick Reference**: [QUICK_DEPLOYMENT.md](./QUICK_DEPLOYMENT.md)
- **Community**: https://codebuff.com/discord
- **Issues**: https://github.com/CodebuffAI/codebuff/issues

## 💡 Pro Tips

1. **Always start web server first** - CLI depends on it for authentication
2. **Use separate terminals** for better visibility of logs
3. **Check health endpoint** if connection issues persist
4. **Use `make dev`** for automated startup
5. **Monitor logs** with `make deploy-logs` (for production)

---

**Remember**: The CLI requires the web server to be running for authentication! The web server handles the OAuth flow and the CLI polls for completion.
