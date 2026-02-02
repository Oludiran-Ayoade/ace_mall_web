# ⚡ Quick Start - Ace Mall Staff Management

## 🎯 What Changed

### ✅ Removed Sign-Up Page
- Sign-up page deleted
- Sign-up route removed from navigation
- "Sign Up" link removed from sign-in page
- **Only HR can create staff accounts** (no self-registration)

### ✅ Added HR Test User
- **Email**: `hr@acemarket.com`
- **Password**: `password123`
- **Role**: Human Resource
- **Can**: Create all staff types, manage departments, promote staff

---

## 📍 Database Credentials Location

### **File to Edit:**
```
/Users/Gracegold/Desktop/Ace App/backend/.env
```

### **What to Update:**
```env
DB_HOST=localhost          # Your PostgreSQL host
DB_PORT=5432              # Your PostgreSQL port
DB_USER=postgres          # ⬅️ YOUR PostgreSQL username
DB_PASSWORD=postgres      # ⬅️ YOUR PostgreSQL password
DB_NAME=ace_mall_db       # Keep this as is
```

---

## 🚀 Setup in 5 Steps

### **1. Update Database Credentials**
```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
nano .env
```
Update `DB_USER` and `DB_PASSWORD` with YOUR PostgreSQL credentials.

### **2. Run Setup Script**
```bash
./setup.sh
```
This creates the database, tables, and inserts default data.

### **3. Create HR User**
```bash
psql -U postgres -d ace_mall_db -f database/seed_hr_user.sql
```
This creates the HR test account.

### **4. Start Backend**
```bash
go run main.go
```
Server runs on `http://localhost:8080`

### **5. Start Flutter App**
```bash
cd /Users/Gracegold/Desktop/Ace\ App/ace_mall_app
flutter run -d chrome
```

---

## 🔐 Login to Test

### **HR Account:**
1. Open app (Chrome/iOS/Android)
2. Wait for intro animation (3 seconds)
3. On sign-in page, enter:
   - **Email**: `hr@acemarket.com`
   - **Password**: `password123`
4. Click "Sign In"

---

## 📊 What's in the Database

After running setup, you'll have:

- ✅ **13 Branches** - All Ace Mall locations
- ✅ **6 Departments** - SuperMarket, Eatery, Lounge, Fun & Arcade, Compliance, Facility
- ✅ **5 Sub-departments** - Cinema, Photo Studio, Saloon, Arcade, Casino
- ✅ **60+ Roles** - From CEO to General Staff
- ✅ **1 HR User** - Ready to login and create staff

---

## 🎯 User Flow

### **For HR (After Login):**
1. **Dashboard** → View overview
2. **Create Staff** → Add new employees
3. **Manage Departments** → Add/edit departments
4. **Promote Staff** → Change roles
5. **View Reports** → Staff analytics

### **For Other Staff (Created by HR):**
1. **Login** → With credentials created by HR
2. **View Profile** → See personal information
3. **View Schedule** → Check assigned shifts
4. **View Reviews** → Performance feedback

---

## 📁 Important Files

| File | Purpose |
|------|---------|
| `/backend/.env` | **Database credentials** (EDIT THIS) |
| `/backend/setup.sh` | Setup script (run once) |
| `/backend/database/seed_hr_user.sql` | Creates HR user |
| `/DATABASE_SETUP.md` | Detailed setup guide |

---

## ✅ Verify Everything Works

### **1. Check Database:**
```bash
psql -U postgres -d ace_mall_db
SELECT * FROM users WHERE email = 'hr@acemarket.com';
\q
```

### **2. Test Backend:**
```bash
curl http://localhost:8080/health
```

### **3. Test Login:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"hr@acemarket.com","password":"password123"}'
```

You should get a JWT token in response.

---

## 🔧 Common Issues

### **"Database connection failed"**
- Check PostgreSQL is running: `brew services list`
- Verify credentials in `.env` file
- Test connection: `psql -U postgres`

### **"HR user not found"**
- Run seed script: `psql -U postgres -d ace_mall_db -f database/seed_hr_user.sql`
- Check: `SELECT * FROM users;`

### **"Backend won't start"**
- Check port 8080 is free: `lsof -i :8080`
- Verify Go dependencies: `go mod tidy`

---

## 🎉 You're Ready!

After setup:
1. ✅ Database configured with YOUR credentials
2. ✅ HR user created (`hr@acemarket.com`)
3. ✅ Backend running on port 8080
4. ✅ Flutter app ready to use
5. ✅ No signup page (HR creates all accounts)

---

## 📚 More Documentation

- **Detailed Setup**: `DATABASE_SETUP.md`
- **Full Guide**: `GETTING_STARTED.md`
- **Implementation Summary**: `IMPLEMENTATION_SUMMARY.md`
- **Backend API**: `backend/README.md`

---

**Default Login**: `hr@acemarket.com` / `password123`

**Change password after first login!**
