# 🔐 Render Deployment Credentials

## All Environment Variables for Render

Copy and paste these into Render's Environment Variables section when deploying your backend.

---

## 📊 Database Configuration

**Note**: These will be automatically provided by Render when you create a PostgreSQL database. Use the values from your Render database dashboard.

```
DB_HOST=<from Render PostgreSQL dashboard>
DB_PORT=5432
DB_USER=<from Render PostgreSQL dashboard>
DB_PASSWORD=<from Render PostgreSQL dashboard>
DB_NAME=aceSuperMarket
```

---

## 🚀 Server Configuration

```
PORT=8080
GIN_MODE=release
```

---

## 🔑 JWT Configuration

```
JWT_SECRET=ace_mall_super_secret_jwt_key_2025_change_in_production
```

**⚠️ IMPORTANT**: For production, generate a new strong secret:
```bash
openssl rand -base64 32
```

---

## 📧 Email Configuration (Gmail SMTP)

```
EMAIL_USER=ooludiranayoade@gmail.com
EMAIL_PASS=ubgy yjoz ifbv zgvk
```

**Email Settings**:
- **Provider**: Gmail SMTP
- **Port**: 587 (TLS)
- **Authentication**: Yes
- **App Password**: Already configured above

---

## ☁️ Cloudinary Configuration

```
CLOUDINARY_CLOUD_NAME=desk7uuna
CLOUDINARY_API_KEY=298988719545274
CLOUDINARY_API_SECRET=H79r0vR_K72aZm_vGHQ1KF1_XXA
CLOUDINARY_UPLOAD_PRESET=flutter_uploads
```

**Cloudinary Dashboard**: https://console.cloudinary.com/

---

## 🗄️ Redis Configuration (Optional)

```
REDIS_HOST=localhost:6379
REDIS_PASSWORD=
REDIS_DB=0
```

**Note**: Redis is optional. If not using Redis on Render, the app will work without caching.

---

## ⚙️ Cache Settings

```
CACHE_ENABLED=true
CACHE_DEFAULT_TTL=900
```

---

## 📋 Complete Environment Variables List

Here's the complete list ready to copy-paste into Render:

```env
# Server
PORT=8080
GIN_MODE=release

# JWT
JWT_SECRET=ace_mall_super_secret_jwt_key_2025_change_in_production

# Database (Get these from Render PostgreSQL dashboard)
DB_HOST=<your-render-db-host>
DB_PORT=5432
DB_USER=<your-render-db-user>
DB_PASSWORD=<your-render-db-password>
DB_NAME=aceSuperMarket

# Email
EMAIL_USER=ooludiranayoade@gmail.com
EMAIL_PASS=ubgy yjoz ifbv zgvk

# Cloudinary
CLOUDINARY_CLOUD_NAME=desk7uuna
CLOUDINARY_API_KEY=298988719545274
CLOUDINARY_API_SECRET=H79r0vR_K72aZm_vGHQ1KF1_XXA
CLOUDINARY_UPLOAD_PRESET=flutter_uploads

# Redis (Optional)
REDIS_HOST=localhost:6379
REDIS_PASSWORD=
REDIS_DB=0

# Cache
CACHE_ENABLED=true
CACHE_DEFAULT_TTL=900
```

---

## 🎯 Quick Deployment Steps

### 1. Create PostgreSQL Database on Render
1. Go to Render Dashboard → New → PostgreSQL
2. Name: `ace-supermarket-db`
3. Database: `aceSuperMarket`
4. Plan: **Free** (or Starter)
5. Click **Create Database**
6. **Copy the credentials** shown (Host, Port, User, Password)

### 2. Deploy Backend
1. Push code to GitHub (if not already done)
2. Render Dashboard → New → Web Service
3. Connect GitHub repo
4. Settings:
   - **Name**: `ace-supermarket-backend`
   - **Runtime**: Go
   - **Build Command**: `go build -o main .`
   - **Start Command**: `./main`
5. Add all environment variables from above
6. Replace DB_HOST, DB_PORT, DB_USER, DB_PASSWORD with values from Step 1
7. Click **Create Web Service**

### 3. Import Database
```bash
# Export local database
cd /Users/Gracegold/Desktop/Ace\ App/backend
PGPASSWORD=Circumspect1 pg_dump -h localhost -p 5433 -U postgres -d aceSuperMarket > backup.sql

# Import to Render (use External Database URL from Render)
psql "<External-Database-URL-from-Render>" < backup.sql
```

### 4. Update Flutter App
In `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://ace-supermarket-backend.onrender.com/api/v1';
```

---

## 🔒 Security Notes

1. **JWT Secret**: Change this in production to a strong random value
2. **Email Password**: This is a Gmail App Password (not your regular password)
3. **Database**: Render provides SSL connections by default
4. **API Keys**: All Cloudinary keys are from your account dashboard

---

## 📞 Support

- **Render Docs**: https://render.com/docs
- **Render Support**: https://community.render.com
- **Your Render Dashboard**: https://dashboard.render.com

---

## ✅ Deployment Checklist

- [ ] Created PostgreSQL database on Render
- [ ] Copied database credentials
- [ ] Pushed backend code to GitHub
- [ ] Created web service on Render
- [ ] Added all environment variables
- [ ] Imported database schema and data
- [ ] Updated Flutter app with production URL
- [ ] Tested login functionality
- [ ] Verified email notifications work

---

**Your backend will be live at**: `https://ace-supermarket-backend.onrender.com`

**Deployment time**: ~15-30 minutes for first deployment
