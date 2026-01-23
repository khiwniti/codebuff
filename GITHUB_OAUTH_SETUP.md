# GitHub OAuth Setup Guide for Codebuff

This guide will walk you through setting up GitHub OAuth authentication for your Codebuff instance.

## Why GitHub OAuth?

Codebuff uses GitHub OAuth to:
- Authenticate users securely
- Access user repositories (with permission)
- Enable GitHub integrations
- Simplify the login process

## Step-by-Step Setup

### 1. Navigate to GitHub Developer Settings

1. Go to your GitHub account
2. Click your profile picture (top right) → **Settings**
3. Scroll down to **Developer settings** (bottom of left sidebar)
4. Click **OAuth Apps**

**Direct link**: https://github.com/settings/developers

### 2. Create a New OAuth App

1. Click **"New OAuth App"** button (or "Register a new application")
2. You'll see a form with the following fields:

### 3. Fill in Application Details

#### For Local Development:

```
Application name: Codebuff Local
Homepage URL: http://localhost:3000
Application description: Codebuff AI-powered coding assistant (optional)
Authorization callback URL: http://localhost:3000/api/auth/callback/github
```

#### For Production (Railway):

```
Application name: Codebuff Production
Homepage URL: https://your-app-name.railway.app
Application description: Codebuff AI-powered coding assistant (optional)
Authorization callback URL: https://your-app-name.railway.app/api/auth/callback/github
```

**Important Notes:**
- Replace `your-app-name.railway.app` with your actual Railway domain
- If using a custom domain, use that instead
- The callback URL must be exact - including `/api/auth/callback/github`
- You may want to create separate OAuth apps for development and production

### 4. Register the Application

1. Click **"Register application"**
2. You'll be taken to your new OAuth app's page

### 5. Get Your Credentials

On your OAuth app page, you'll see:

1. **Client ID**: This is visible immediately
   - Copy this value
   - Example: `Iv1.a12b34c56d78e90f`

2. **Client Secret**: Click **"Generate a new client secret"**
   - Copy this value immediately (you won't be able to see it again!)
   - Example: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0`

**⚠️ Warning**: Treat your Client Secret like a password. Never commit it to version control or share it publicly.

### 6. Add Credentials to Your Environment

#### For Local Development:

Edit your `.env.local` file:

```bash
CODEBUFF_GITHUB_ID=Iv1.a12b34c56d78e90f
CODEBUFF_GITHUB_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

#### For Production (Railway):

Set environment variables in Railway:

```bash
railway variables set CODEBUFF_GITHUB_ID=Iv1.a12b34c56d78e90f
railway variables set CODEBUFF_GITHUB_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

Or via Railway Dashboard:
1. Go to your Railway project
2. Click on your service
3. Go to **Variables** tab
4. Click **New Variable**
5. Add both `CODEBUFF_GITHUB_ID` and `CODEBUFF_GITHUB_SECRET`

### 7. Update Application URLs (After Deployment)

If you used a temporary URL and later get your actual Railway domain:

1. Go back to your GitHub OAuth app settings
2. Update **Homepage URL** and **Authorization callback URL**
3. Update `NEXT_PUBLIC_CODEBUFF_APP_URL` in Railway:
   ```bash
   railway variables set NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-actual-domain.railway.app
   ```

### 8. Test the OAuth Flow

1. Start your application (local or deployed)
2. Navigate to the login page
3. Click "Sign in with GitHub"
4. You should be redirected to GitHub's authorization page
5. Click "Authorize"
6. You should be redirected back to your application, now logged in

## Troubleshooting

### Error: "The redirect_uri MUST match the registered callback URL for this application"

**Problem**: The callback URL doesn't match what's registered in GitHub.

**Solutions**:
- Verify the callback URL in GitHub exactly matches: `https://your-domain/api/auth/callback/github`
- Check for trailing slashes (they matter!)
- Make sure you're using the correct protocol (http vs https)
- Verify `NEXT_PUBLIC_CODEBUFF_APP_URL` matches your actual domain

### Error: "Client authentication failed"

**Problem**: Invalid Client ID or Secret.

**Solutions**:
- Double-check your `CODEBUFF_GITHUB_ID` value
- Regenerate your Client Secret in GitHub and update the environment variable
- Make sure there are no extra spaces or quotes in your environment variables
- Restart your application after updating environment variables

### OAuth Works Locally But Not in Production

**Solutions**:
- Make sure you created a separate OAuth app for production
- Verify the production callback URL is correct
- Check that environment variables are set in Railway
- Redeploy after changing environment variables

### Users Can't Authorize / Permission Errors

**Solutions**:
- Check that your GitHub OAuth app is not suspended
- Verify the app has the correct scopes (default scopes are usually sufficient)
- Make sure users aren't hitting GitHub's OAuth rate limits

## OAuth App Scopes

Codebuff uses these OAuth scopes:
- `user:email` - Access user email address
- `read:user` - Read user profile information
- Default scopes are usually sufficient for basic authentication

If you need additional permissions (e.g., repository access), you can configure them in:
- `web/src/app/api/auth/[...nextauth]/route.ts` (or similar NextAuth configuration)

## Security Best Practices

1. **Never commit secrets**: Keep `.env.local` in `.gitignore`
2. **Use separate apps**: Create different OAuth apps for dev, staging, and production
3. **Rotate secrets**: Regularly regenerate client secrets
4. **Monitor usage**: Check GitHub OAuth app settings for unusual activity
5. **Limit scope**: Only request the OAuth scopes you actually need
6. **Use HTTPS**: Always use HTTPS in production
7. **Validate redirects**: NextAuth handles this, but be aware of redirect validation

## Multiple OAuth Apps (Recommended Setup)

For a professional setup, create three separate OAuth apps:

### Development
```
Name: Codebuff Dev
Homepage: http://localhost:3000
Callback: http://localhost:3000/api/auth/callback/github
```

### Staging (Optional)
```
Name: Codebuff Staging
Homepage: https://codebuff-staging.railway.app
Callback: https://codebuff-staging.railway.app/api/auth/callback/github
```

### Production
```
Name: Codebuff Production
Homepage: https://codebuff.com (or your domain)
Callback: https://codebuff.com/api/auth/callback/github
```

This separation provides:
- Better security
- Clearer usage analytics
- Easier debugging
- Independent credentials for each environment

## Managing Your OAuth App

### View App Settings
1. Go to https://github.com/settings/developers
2. Click on your OAuth app

### Regenerate Client Secret
1. Go to your OAuth app settings
2. Click "Generate a new client secret"
3. Update environment variables everywhere the old secret was used
4. The old secret will stop working after regeneration

### Delete OAuth App
1. Go to your OAuth app settings
2. Scroll to bottom
3. Click "Delete application"
4. **Warning**: This will break authentication for all users!

### View OAuth App Usage
- GitHub shows you statistics about your OAuth app
- Number of users who have authorized
- Token usage and activity

## Transferring OAuth App to Organization

If you want the OAuth app under an organization account:

1. Go to OAuth app settings
2. Click "Transfer ownership"
3. Enter the organization name
4. Organization admin must accept the transfer

## Additional Resources

- [GitHub OAuth Documentation](https://docs.github.com/en/apps/oauth-apps)
- [NextAuth.js GitHub Provider](https://next-auth.js.org/providers/github)
- [Codebuff Documentation](https://codebuff.com/docs)

## Quick Reference

### Required Environment Variables
```bash
CODEBUFF_GITHUB_ID=<your_client_id>
CODEBUFF_GITHUB_SECRET=<your_client_secret>
NEXTAUTH_SECRET=<random_32_char_string>
NEXT_PUBLIC_CODEBUFF_APP_URL=<your_app_url>
```

### Generate NextAuth Secret
```bash
openssl rand -base64 32
```

### Test OAuth Locally
1. Set environment variables in `.env.local`
2. Run `bun run dev`
3. Go to http://localhost:3000/login
4. Click "Sign in with GitHub"

### Set Railway Variables
```bash
railway variables set CODEBUFF_GITHUB_ID=your_id
railway variables set CODEBUFF_GITHUB_SECRET=your_secret
railway variables set NEXTAUTH_SECRET=$(openssl rand -base64 32)
railway variables set NEXT_PUBLIC_CODEBUFF_APP_URL=https://your-app.railway.app
```

---

**Need Help?**
- Codebuff Discord: https://codebuff.com/discord
- GitHub OAuth Docs: https://docs.github.com/en/apps/oauth-apps
- NextAuth Docs: https://next-auth.js.org
