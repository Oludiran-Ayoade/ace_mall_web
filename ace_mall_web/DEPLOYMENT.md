# Ace Mall Web App - Deployment Guide

## 🚀 Quick Deployment to Netlify

### Prerequisites
- GitHub account
- Netlify account (free tier works)

### Step 1: Push to GitHub

The repository has been initialized. Follow these steps:

1. **Create a new repository on GitHub:**
   - Go to https://github.com/new
   - Name: `ace-mall-web-app`
   - Description: `Ace Mall Staff Management Web Application`
   - **DO NOT** initialize with README, .gitignore, or license
   - Click "Create repository"

2. **Push your code:**
   ```bash
   cd "/Users/Gracegold/Desktop/Ace App/ace_mall_web"
   git remote add origin https://github.com/YOUR_USERNAME/ace-mall-web-app.git
   git branch -M main
   git push -u origin main
   ```

### Step 2: Deploy to Netlify

#### Option A: Netlify UI (Recommended)

1. **Login to Netlify:**
   - Go to https://app.netlify.com/
   - Sign in with GitHub

2. **Import your project:**
   - Click "Add new site" → "Import an existing project"
   - Choose "Deploy with GitHub"
   - Authorize Netlify to access your GitHub
   - Select `ace-mall-web-app` repository

3. **Configure build settings:**
   - **Build command:** `npm run build`
   - **Publish directory:** `.next`
   - **Node version:** 18

4. **Add environment variables:**
   - Click "Show advanced"
   - Add variable:
     - Key: `NEXT_PUBLIC_API_URL`
     - Value: `https://ace-supermarket-backend.onrender.com/api/v1`

5. **Deploy:**
   - Click "Deploy site"
   - Wait 2-3 minutes for deployment to complete
   - Your site will be live at `https://random-name.netlify.app`

6. **Custom domain (Optional):**
   - Go to "Domain settings"
   - Click "Add custom domain" to use your own domain

#### Option B: Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Initialize and deploy
netlify init

# Follow the prompts:
# - Create & configure a new site
# - Choose your team
# - Site name: ace-mall-web-app
# - Build command: npm run build
# - Publish directory: .next

# Deploy
netlify deploy --prod
```

### Step 3: Environment Variables

Make sure to set the following environment variable in Netlify:

```
NEXT_PUBLIC_API_URL=https://ace-supermarket-backend.onrender.com/api/v1
```

**To add in Netlify UI:**
1. Go to your site dashboard
2. Click "Site settings"
3. Navigate to "Environment variables"
4. Click "Add a variable"
5. Add the variable above
6. Click "Save"
7. Trigger a new deployment

### Post-Deployment Checklist

- ✅ Web app loads successfully
- ✅ Can navigate to login page
- ✅ API calls work (check browser console)
- ✅ Staff profiles display correctly
- ✅ All dashboard features functional

### Troubleshooting

**Issue: API calls failing**
- Check that `NEXT_PUBLIC_API_URL` is set correctly
- Verify backend is running on Render
- Check browser console for CORS errors

**Issue: Build fails**
- Check Netlify build logs
- Ensure Node version is 18
- Verify all dependencies are in package.json

**Issue: 404 on page refresh**
- Netlify should handle this automatically with the redirects in `netlify.toml`
- If not working, check that `netlify.toml` is committed to git

### Your Deployed App

After deployment, your app will be available at:
- **Netlify URL:** `https://[your-site-name].netlify.app`
- **Custom domain:** (if configured)

### Backend API

The app connects to:
- **Production API:** `https://ace-supermarket-backend.onrender.com/api/v1`

---

## 🔧 Local Development

To run locally:

```bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env.local

# Update .env.local with your API URL
# NEXT_PUBLIC_API_URL=http://localhost:8080/api/v1

# Run development server
npm run dev

# Open http://localhost:3000
```

## 📦 Tech Stack

- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **UI Components:** shadcn/ui
- **State Management:** React Context + React Query
- **Deployment:** Netlify
- **Backend:** Go (Gin) on Render

## 🎯 Features

- ✅ Role-based dashboards (CEO, COO, HR, Auditor, Floor Manager, Staff)
- ✅ Staff management (create, view, edit, promote, transfer, terminate)
- ✅ Comprehensive staff profiles with work history, education, guarantors
- ✅ Department & branch management
- ✅ Roster scheduling system
- ✅ Performance reviews
- ✅ Promotion tracking
- ✅ Reports & analytics
- ✅ Notifications system

---

**Need Help?** Check the Netlify docs: https://docs.netlify.com/
