# 🚀 Quick Start: Deploy to Render in 15 Minutes

## Step 1: Push to GitHub (5 minutes)
```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
git init
git add .
git commit -m "Initial commit"
# Create repo at github.com/new then:
git remote add origin https://github.com/YOUR_USERNAME/ace-supermarket-backend.git
git push -u origin main
```

## Step 2: Create Render Account (2 minutes)
1. Go to https://render.com
2. Sign up with GitHub
3. Verify email

## Step 3: Create Database (3 minutes)
1. Click "New +" → "PostgreSQL"
2. Name: `ace-supermarket-db`
3. Database: `aceSuperMarket`
4. Plan: **Free**
5. Click "Create Database"
6. **Save the credentials shown**

## Step 4: Import Database (2 minutes)
```bash
# Export local database
PGPASSWORD=Circumspect1 pg_dump -h localhost -p 5433 -U postgres -d aceSuperMarket > backup.sql

# Import to Render (use External Database URL from Render)
psql "postgresql://USER:PASSWORD@HOST/DATABASE" < backup.sql
```

## Step 5: Deploy Backend (3 minutes)
1. Click "New +" → "Web Service"
2. Connect GitHub repo: `ace-supermarket-backend`
3. Settings:
   - **Name**: `ace-supermarket-backend`
   - **Runtime**: Go
   - **Build**: `go build -o main .`
   - **Start**: `./main`
   - **Plan**: Free

4. Add Environment Variables (copy from your .env):
   ```
   PORT=8080
   GIN_MODE=release
   JWT_SECRET=ace_mall_super_secret_jwt_key_2025_change_in_production
   DB_HOST=<from Render DB>
   DB_PORT=<from Render DB>
   DB_USER=<from Render DB>
   DB_PASSWORD=<from Render DB>
   DB_NAME=aceSuperMarket
   EMAIL_USER=ooludiranayoade@gmail.com
   EMAIL_PASS=ubgy yjoz ifbv zgvk
   CLOUDINARY_CLOUD_NAME=desk7uuna
   CLOUDINARY_API_KEY=298988719545274
   CLOUDINARY_API_SECRET=H79r0vR_K72aZm_vGHQ1KF1_XXA
   CLOUDINARY_UPLOAD_PRESET=flutter_uploads
   ```

5. Click "Create Web Service"
6. Wait 5-10 minutes for deployment

## Step 6: Update Flutter App
In `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://YOUR-APP-NAME.onrender.com/api/v1';
```

## ✅ Done!
Your backend is now live at: `https://YOUR-APP-NAME.onrender.com`

Test it: `https://YOUR-APP-NAME.onrender.com/health`

## 🔄 Future Updates
```bash
git add .
git commit -m "Update feature"
git push origin main
# Render auto-deploys in 2-3 minutes!
```

---

**Full Guide**: See `RENDER_DEPLOYMENT_GUIDE.md` for detailed instructions
