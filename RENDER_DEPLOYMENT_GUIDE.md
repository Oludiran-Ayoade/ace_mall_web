# 🚀 Comprehensive Guide: Deploy Ace Supermarket Backend to Render

This guide will walk you through deploying your Go backend to Render, eliminating the need to constantly change IP addresses for testing.

---

## 📋 **Prerequisites**

1. **GitHub Account** - Your code needs to be in a GitHub repository
2. **Render Account** - Sign up at https://render.com (free tier available)
3. **PostgreSQL Database** - Render provides free PostgreSQL databases

---

## 🎯 **Benefits of Deploying to Render**

✅ **No More IP Changes** - Get a permanent URL like `https://ace-supermarket.onrender.com`
✅ **Automatic HTTPS** - Secure connections by default
✅ **Free Tier Available** - Start with free hosting
✅ **Auto-Deploy** - Pushes to GitHub automatically deploy
✅ **Managed Database** - PostgreSQL database included
✅ **Environment Variables** - Secure credential management

---

## 📦 **Step 1: Prepare Your Backend for Deployment**

### 1.1 Create a `.gitignore` file (if not exists)

Create `/backend/.gitignore`:
```
# Environment variables
.env

# Build files
main
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test files
*.test
*.out

# Uploads
uploads/
*.log

# IDE
.vscode/
.idea/
*.swp
*.swo
```

### 1.2 Update `main.go` to use PORT from environment

Your `main.go` already does this correctly:
```go
port := os.Getenv("PORT")
if port == "" {
    port = "8080"
}
```

### 1.3 Create `go.mod` and `go.sum` (if not exists)

Run in `/backend` directory:
```bash
go mod init ace-mall-backend
go mod tidy
```

---

## 🗄️ **Step 2: Push Your Code to GitHub**

### 2.1 Initialize Git Repository

```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
git init
git add .
git commit -m "Initial commit - Ace Supermarket Backend"
```

### 2.2 Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `ace-supermarket-backend`
3. Description: "Backend API for Ace Supermarket Staff Management"
4. Make it **Private** (recommended)
5. Click "Create repository"

### 2.3 Push to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/ace-supermarket-backend.git
git branch -M main
git push -u origin main
```

---

## 🎨 **Step 3: Create Render Account & Deploy**

### 3.1 Sign Up for Render

1. Go to https://render.com
2. Click "Get Started for Free"
3. Sign up with GitHub (recommended) or email
4. Verify your email

### 3.2 Create PostgreSQL Database

1. In Render Dashboard, click "**New +**" → "**PostgreSQL**"
2. Fill in details:
   - **Name**: `ace-supermarket-db`
   - **Database**: `aceSuperMarket`
   - **User**: `postgres` (default)
   - **Region**: Choose closest to you (e.g., Oregon, Frankfurt)
   - **Plan**: **Free** (or Starter if you need more)
3. Click "**Create Database**"
4. Wait 2-3 minutes for database to provision
5. **Save these credentials** (you'll need them):
   - Internal Database URL
   - External Database URL
   - Host
   - Port
   - Database Name
   - Username
   - Password

### 3.3 Import Your Database Schema

1. In Render Dashboard, click on your database
2. Click "**Connect**" → Copy the **External Database URL**
3. On your local machine, run:

```bash
# Export your local database
cd /Users/Gracegold/Desktop/Ace\ App/backend
PGPASSWORD=Circumspect1 pg_dump -h localhost -p 5433 -U postgres -d aceSuperMarket > database_backup.sql

# Import to Render (replace with your External Database URL)
psql "postgresql://postgres:PASSWORD@HOST/DATABASE" < database_backup.sql
```

Or use Render's built-in SQL editor:
1. Click "**Connect**" → "**PSQL**"
2. Copy and paste your schema from `/backend/database/schema.sql`
3. Run the SQL commands

### 3.4 Create Web Service

1. In Render Dashboard, click "**New +**" → "**Web Service**"
2. Connect your GitHub repository:
   - Click "**Connect account**" if first time
   - Select `ace-supermarket-backend` repository
3. Fill in service details:
   - **Name**: `ace-supermarket-backend`
   - **Region**: Same as your database
   - **Branch**: `main`
   - **Root Directory**: Leave blank (or `backend` if repo has multiple folders)
   - **Runtime**: **Go**
   - **Build Command**: `go build -o main .`
   - **Start Command**: `./main`
   - **Plan**: **Free** (or Starter for better performance)

### 3.5 Configure Environment Variables

In the "Environment" section, add these variables:

| Key | Value | Notes |
|-----|-------|-------|
| `PORT` | `8080` | Render will override this |
| `GIN_MODE` | `release` | Production mode |
| `JWT_SECRET` | `your-super-secret-jwt-key-change-this` | Generate a strong secret |
| `DB_HOST` | From Render DB | Copy from database details |
| `DB_PORT` | From Render DB | Usually `5432` |
| `DB_USER` | From Render DB | Usually `postgres` |
| `DB_PASSWORD` | From Render DB | Copy from database details |
| `DB_NAME` | `aceSuperMarket` | Your database name |
| `EMAIL_USER` | `ooludiranayoade@gmail.com` | Your email |
| `EMAIL_PASS` | `ubgy yjoz ifbv zgvk` | Your Gmail app password |
| `CLOUDINARY_CLOUD_NAME` | `desk7uuna` | Your Cloudinary cloud name |
| `CLOUDINARY_API_KEY` | `298988719545274` | Your Cloudinary API key |
| `CLOUDINARY_API_SECRET` | `H79r0vR_K72aZm_vGHQ1KF1_XXA` | Your Cloudinary secret |
| `CLOUDINARY_UPLOAD_PRESET` | `flutter_uploads` | Your upload preset |
| `REDIS_HOST` | `localhost:6379` | Optional - disable if not using |
| `REDIS_PASSWORD` | `` | Leave empty |
| `REDIS_DB` | `0` | Default |
| `CACHE_ENABLED` | `true` | Enable caching |
| `CACHE_DEFAULT_TTL` | `900` | 15 minutes |

**Important**: Click "**Add Secret File**" if you want to use `.env` file instead.

### 3.6 Deploy

1. Click "**Create Web Service**"
2. Render will:
   - Clone your repository
   - Install Go dependencies
   - Build your application
   - Start the server
3. Wait 5-10 minutes for first deployment
4. You'll get a URL like: `https://ace-supermarket-backend.onrender.com`

---

## 📱 **Step 4: Update Flutter App to Use Render URL**

### 4.1 Create Environment-Based Configuration

Update `/ace_mall_app/lib/services/api_service.dart`:

```dart
class ApiService {
  // Environment-based URL configuration
  static const bool useProduction = true; // Set to true for production
  
  static String get baseUrl {
    if (useProduction) {
      // Production URL from Render
      return 'https://ace-supermarket-backend.onrender.com/api/v1';
    } else {
      // Local development
      return 'http://10.116.118.250:8080/api/v1';
    }
  }
  
  // Rest of your code...
}
```

### 4.2 Test the Connection

1. Set `useProduction = true`
2. Run your Flutter app
3. Try to sign in with: `john@acemarket.com` / `password`
4. Should work without IP issues!

---

## 🔧 **Step 5: Ongoing Maintenance**

### 5.1 Auto-Deploy on Git Push

Every time you push to GitHub, Render automatically deploys:

```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
git add .
git commit -m "Updated email templates"
git push origin main
# Render will auto-deploy in 2-3 minutes
```

### 5.2 View Logs

1. Go to Render Dashboard
2. Click on your web service
3. Click "**Logs**" tab
4. See real-time server logs

### 5.3 Monitor Performance

1. Click "**Metrics**" tab
2. See CPU, Memory, Response times
3. Upgrade plan if needed

---

## 🎯 **Step 6: Database Migrations**

### 6.1 Run Migrations on Render

Option 1: Use Render Shell
1. In your web service, click "**Shell**"
2. Run migration commands:
```bash
psql $DATABASE_URL -f database/migrations/003_password_reset_otps.sql
```

Option 2: Use External Connection
```bash
# From your local machine
psql "YOUR_EXTERNAL_DATABASE_URL" < database/migrations/003_password_reset_otps.sql
```

### 6.2 Automated Migrations (Recommended)

Add to your `main.go` before starting server:

```go
func runMigrations() {
    // Run migrations automatically on startup
    migrationFiles := []string{
        "database/migrations/001_initial_schema.sql",
        "database/migrations/002_add_features.sql",
        "database/migrations/003_password_reset_otps.sql",
    }
    
    for _, file := range migrationFiles {
        content, err := os.ReadFile(file)
        if err != nil {
            log.Printf("Warning: Could not read migration %s: %v", file, err)
            continue
        }
        
        _, err = config.DB.Exec(string(content))
        if err != nil {
            log.Printf("Warning: Migration %s failed: %v", file, err)
        } else {
            log.Printf("✅ Migration %s completed", file)
        }
    }
}

// In main():
func main() {
    // ... existing code ...
    
    if err := config.ConnectDatabase(); err != nil {
        log.Fatal("Failed to connect to database:", err)
    }
    defer config.CloseDatabase()
    
    // Run migrations
    runMigrations()
    
    // ... rest of code ...
}
```

---

## 🔒 **Step 7: Security Best Practices**

### 7.1 Environment Variables

✅ **Never commit `.env` to GitHub**
✅ **Use Render's environment variables**
✅ **Rotate secrets regularly**
✅ **Use strong JWT secrets**

### 7.2 Database Security

✅ **Use Render's internal database URL** (faster, more secure)
✅ **Enable SSL connections**
✅ **Regular backups** (Render does this automatically)

### 7.3 API Security

✅ **Enable CORS properly** (already configured)
✅ **Use HTTPS only** (Render provides this)
✅ **Rate limiting** (consider adding)

---

## 💰 **Step 8: Cost Optimization**

### Free Tier Limits (Render)
- **Web Service**: 750 hours/month (enough for 1 service 24/7)
- **PostgreSQL**: 1GB storage, 97 hours/month compute
- **Bandwidth**: 100GB/month
- **Builds**: 500 build minutes/month

### When to Upgrade
- **Web Service**: If app sleeps (free tier spins down after 15 min inactivity)
- **Database**: If you need >1GB or 24/7 uptime
- **Performance**: If response times are slow

**Starter Plan**: $7/month (web service) + $7/month (database) = $14/month total

---

## 🐛 **Troubleshooting**

### Issue: Build Fails

**Solution**: Check build logs in Render dashboard
- Ensure `go.mod` and `go.sum` are committed
- Verify build command: `go build -o main .`
- Check for missing dependencies

### Issue: Database Connection Fails

**Solution**: 
- Verify environment variables are correct
- Use **Internal Database URL** (faster)
- Check database is running in Render dashboard

### Issue: App Crashes on Startup

**Solution**: Check logs for errors
- Missing environment variables?
- Database migration issues?
- Port binding issues?

### Issue: Emails Not Sending

**Solution**:
- Verify `EMAIL_USER` and `EMAIL_PASS` are set
- Check Gmail app password is correct
- Look for email errors in logs

---

## 📊 **Monitoring & Alerts**

### Set Up Alerts

1. In Render Dashboard → Your Service
2. Click "**Settings**" → "**Notifications**"
3. Add email for:
   - Deploy failures
   - Service crashes
   - High CPU/Memory usage

### Health Checks

Render automatically monitors your `/health` endpoint:
- Returns 200 = Healthy
- Returns 5xx = Unhealthy (will restart)

---

## 🎉 **Final Checklist**

- [ ] Code pushed to GitHub
- [ ] Render account created
- [ ] PostgreSQL database created and populated
- [ ] Web service created and deployed
- [ ] Environment variables configured
- [ ] Flutter app updated with production URL
- [ ] Tested login functionality
- [ ] Email notifications working
- [ ] Monitoring/alerts set up

---

## 📞 **Support Resources**

- **Render Docs**: https://render.com/docs
- **Render Community**: https://community.render.com
- **Go Deployment**: https://render.com/docs/deploy-go

---

## 🚀 **Your Production URLs**

After deployment, you'll have:

- **Backend API**: `https://ace-supermarket-backend.onrender.com`
- **Health Check**: `https://ace-supermarket-backend.onrender.com/health`
- **API Docs**: `https://ace-supermarket-backend.onrender.com/api/v1`

Update your Flutter app's `baseUrl` to use the production URL, and you'll never have IP address issues again!

---

**Deployment Time**: ~30 minutes first time, ~5 minutes for updates

**Result**: Professional, production-ready backend with permanent URL! 🎊
