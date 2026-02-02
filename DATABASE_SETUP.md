# 🗄️ Database Setup Guide - Ace Mall Staff Management

## 📍 Where to Configure Database Credentials

### **File Location:**
```
/Users/Gracegold/Desktop/Ace App/backend/.env
```

### **Current Configuration:**
```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=ace_mall_db

# Server Configuration
PORT=8080
GIN_MODE=debug

# JWT Configuration
JWT_SECRET=ace_mall_super_secret_jwt_key_2025_change_in_production
```

---

## 🔧 How to Update Database Credentials

### **Option 1: Edit the .env file directly**

```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
nano .env
```

Then update these values with YOUR PostgreSQL credentials:
```env
DB_HOST=localhost          # Your PostgreSQL host (usually localhost)
DB_PORT=5432              # Your PostgreSQL port (default is 5432)
DB_USER=your_username     # Your PostgreSQL username
DB_PASSWORD=your_password # Your PostgreSQL password
DB_NAME=ace_mall_db       # Database name (keep as is)
```

### **Option 2: Use a text editor**

1. Open Finder
2. Navigate to: `/Users/Gracegold/Desktop/Ace App/backend/`
3. Open `.env` file with TextEdit or VS Code
4. Update the database credentials
5. Save the file

---

## 🚀 Complete Setup Steps

### **Step 1: Install PostgreSQL (if not installed)**

```bash
# macOS
brew install postgresql@14
brew services start postgresql@14

# Check if PostgreSQL is running
psql --version
```

### **Step 2: Create PostgreSQL User (if needed)**

```bash
# Access PostgreSQL
psql postgres

# Create user with password
CREATE USER postgres WITH PASSWORD 'postgres';
ALTER USER postgres WITH SUPERUSER;

# Exit
\q
```

### **Step 3: Update .env with YOUR credentials**

Edit `/Users/Gracegold/Desktop/Ace App/backend/.env`:
```env
DB_USER=postgres          # Your PostgreSQL username
DB_PASSWORD=postgres      # Your PostgreSQL password
```

### **Step 4: Run Setup Script**

```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
./setup.sh
```

This will:
- ✅ Create database `ace_mall_db`
- ✅ Create all tables (20+ tables)
- ✅ Insert 13 branches
- ✅ Insert 6 departments
- ✅ Insert 60+ roles
- ✅ Install Go dependencies

### **Step 5: Seed HR User**

```bash
# Still in backend directory
psql -U postgres -d ace_mall_db -f database/seed_hr_user.sql
```

This creates an HR user:
- **Email**: `hr@acemarket.com`
- **Password**: `password123`

---

## ✅ Verify Setup

### **Check Database Connection:**

```bash
# Connect to database
psql -U postgres -d ace_mall_db

# Check tables
\dt

# Check branches
SELECT * FROM branches;

# Check roles
SELECT COUNT(*) FROM roles;

# Check HR user
SELECT email, full_name FROM users WHERE email = 'hr@acemarket.com';

# Exit
\q
```

Expected results:
- **20+ tables** created
- **13 branches** in branches table
- **60+ roles** in roles table
- **1 HR user** with email hr@acemarket.com

---

## 🔐 Test Login Credentials

### **HR User (Created by seed script):**
- **Email**: `hr@acemarket.com`
- **Password**: `password123`
- **Role**: Human Resource
- **Permissions**: Can create ALL staff types

### **Test Login:**

```bash
# Start backend server
cd /Users/Gracegold/Desktop/Ace\ App/backend
go run main.go

# In another terminal, test login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"hr@acemarket.com","password":"password123"}'
```

You should get a response with a JWT token.

---

## 🎯 Quick Start Commands

```bash
# 1. Navigate to backend
cd /Users/Gracegold/Desktop/Ace\ App/backend

# 2. Update .env with your credentials
nano .env

# 3. Run setup
./setup.sh

# 4. Seed HR user
psql -U postgres -d ace_mall_db -f database/seed_hr_user.sql

# 5. Start backend
go run main.go

# 6. In new terminal, start Flutter app
cd /Users/Gracegold/Desktop/Ace\ App/ace_mall_app
flutter run -d chrome
```

---

## 🔍 Troubleshooting

### **Error: "role 'postgres' does not exist"**

```bash
# Create the postgres user
psql postgres
CREATE USER postgres WITH PASSWORD 'postgres' SUPERUSER;
\q
```

### **Error: "database 'ace_mall_db' does not exist"**

```bash
# Create database manually
psql -U postgres
CREATE DATABASE ace_mall_db;
\q

# Then run setup script again
./setup.sh
```

### **Error: "password authentication failed"**

1. Check your `.env` file has correct password
2. Update PostgreSQL password:
```bash
psql postgres
ALTER USER postgres WITH PASSWORD 'your_new_password';
\q
```
3. Update `.env` with new password

### **Error: "connection refused"**

```bash
# Check if PostgreSQL is running
brew services list | grep postgresql

# Start PostgreSQL
brew services start postgresql@14
```

---

## 📊 Database Structure

### **Created Tables:**
- `users` - Staff profiles
- `branches` - 13 mall locations
- `departments` - 6 main departments
- `sub_departments` - 5 sub-departments
- `roles` - 60+ job positions
- `user_hierarchy` - Manager relationships
- `user_documents` - Document uploads
- `next_of_kin` - Emergency contacts
- `guarantors` - Guarantor information
- `work_experience` - Employment history
- `role_history` - Promotions
- `rosters` - Weekly schedules
- `weekly_reviews` - Performance reviews
- `terminated_staff` - Historical records
- And more...

---

## 🎉 Success Checklist

- ✅ PostgreSQL installed and running
- ✅ `.env` file updated with correct credentials
- ✅ Setup script executed successfully
- ✅ Database `ace_mall_db` created
- ✅ All tables created (20+)
- ✅ HR user seeded
- ✅ Backend server starts without errors
- ✅ Can login with `hr@acemarket.com` / `password123`

---

## 📝 Default Login Credentials

After setup, you can login with:

| Email | Password | Role |
|-------|----------|------|
| hr@acemarket.com | password123 | Human Resource |

**Note:** The signup page has been removed. Only HR can create new staff accounts through the admin panel.

---

## 🔒 Security Notes

1. **Change default password** after first login
2. **Update JWT_SECRET** in `.env` for production
3. **Never commit** `.env` file to version control
4. **Use strong passwords** for database users
5. **Enable SSL** for production database connections

---

## 📞 Need Help?

If you encounter issues:
1. Check PostgreSQL is running: `brew services list`
2. Verify credentials in `.env` file
3. Check backend logs when starting server
4. Test database connection: `psql -U postgres -d ace_mall_db`

---

**Location**: `/Users/Gracegold/Desktop/Ace App/backend/.env`
