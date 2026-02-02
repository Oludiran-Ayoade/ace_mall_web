# 🚀 Ace Mall Staff Management - Quick Start Guide

## ✅ Prerequisites Completed

- ✅ PostgreSQL database `aceSuperMarket` created
- ✅ Database schema set up with all tables
- ✅ 13 Branches populated
- ✅ 6 Departments populated
- ✅ HR user created and ready to use

---

## 🎯 How to Run the Application

### **Step 1: Start the Backend Server**

Open a terminal and run:

```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
go run main.go
```

You should see:
```
✅ Database connected successfully
🚀 Server starting on port 8080
[GIN-debug] Listening and serving HTTP on :8080
```

**Keep this terminal open!** The backend must stay running.

---

### **Step 2: Start the Flutter App**

Open a **new terminal** (keep the backend running) and run:

```bash
cd /Users/Gracegold/Desktop/Ace\ App/ace_mall_app
flutter run -d chrome
```

The app will open in Chrome automatically.

---

## 🔑 Login Credentials

### **HR Administrator**
- **Email**: `hr@acemarket.com`
- **Password**: `password123`

---

## 📱 What You'll See

### **1. Intro Screen (3 seconds)**
- Ace SuperMarket logo with animation
- Automatically transitions to sign-in

### **2. Sign-In Page**
- Enter HR credentials
- Click "Sign In"
- Loading spinner appears

### **3. HR Dashboard**
Once logged in, you'll see:

#### **Welcome Header**
- Green gradient background
- "Welcome, HR Administrator"

#### **Quick Stats**
- **Total Staff**: 0 (no staff added yet)
- **Branches**: 13

#### **Action Cards**
1. **✅ Create Staff Profile** - Click to start adding staff
2. **View All Staff** - View all employees
3. **Manage Departments** - Department management
4. **Promote Staff** - Handle promotions
5. **Reports & Analytics** - View reports

---

## 🎨 Current Features

### ✅ **Completed**
- Intro animation with logo
- Sign-in page with authentication
- HR Dashboard with stats and actions
- Backend API for login
- Database with branches and departments
- JWT token authentication

### 🚧 **In Progress**
- Staff profile creation flow
- Department selection page
- File upload system
- HR management APIs

---

## 🗄️ Database Information

### **Connection Details**
- **Host**: localhost
- **Port**: 5433
- **Database**: aceSuperMarket
- **User**: postgres
- **Password**: Circumspect1

### **Tables Created**
- `branches` - 13 branches across Nigeria
- `departments` - 6 main departments
- `sub_departments` - 5 sub-departments for Fun & Arcade
- `roles` - Staff roles and positions
- `users` - All staff members
- And more...

---

## 🔧 Troubleshooting

### **Backend won't start**
```bash
# Check if port 8080 is already in use
lsof -i :8080

# Kill the process if needed
kill -9 <PID>
```

### **Database connection error**
```bash
# Verify PostgreSQL is running
psql -h localhost -p 5433 -U postgres -d aceSuperMarket -c "SELECT 1;"
```

### **Login fails**
- Make sure backend is running on port 8080
- Check credentials: `hr@acemarket.com` / `password123`
- Check browser console for errors

---

## 📊 Database Setup Script

If you need to reset the database:

```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
PGPASSWORD=Circumspect1 psql -h localhost -p 5433 -U postgres -d aceSuperMarket -f database/setup_complete.sql
```

This will:
- Create all tables
- Insert 13 branches
- Insert 6 departments
- Create HR user with proper credentials

---

## 🎯 Next Steps

1. **Click "Create Staff Profile"** on HR Dashboard
2. **Select Staff Type**: Senior Admin, Admin, or General Staff
3. **Choose Role**: Based on staff type
4. **Select Branch**: From 13 available branches
5. **Select Department**: From 6 departments
6. **Fill Profile**: Personal info, education, documents
7. **Add Next of Kin**: Emergency contact
8. **Add Guarantors**: Two guarantors required
9. **Submit**: Create staff profile

---

## 📞 Support

If you encounter any issues:
1. Check both terminals are running (backend + flutter)
2. Verify database connection
3. Check browser console for errors
4. Ensure all dependencies are installed

---

## 🎉 You're All Set!

The application is ready to use. Start by logging in with the HR credentials and exploring the dashboard!

**Backend**: http://localhost:8080
**Frontend**: http://localhost:port (Flutter assigns port)
**Database**: aceSuperMarket on port 5433
