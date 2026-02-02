# 🔄 Complete Restart Instructions

## ✅ Backend is Running
The backend server has been restarted and is running on port 8080.

## 📱 Restart Flutter App (iOS Simulator)

### **Step 1: Stop Current App**
In your Flutter terminal, press **`q`** to quit the app.

### **Step 2: Clean Build (Optional but Recommended)**
```bash
cd /Users/Gracegold/Desktop/Ace\ App/ace_mall_app
flutter clean
flutter pub get
```

### **Step 3: Start Fresh**
```bash
flutter run
```

This will automatically detect your iOS Simulator and run on it.

### **Step 4: Wait for App to Load**
- Wait for compilation (may take 1-2 minutes)
- App will launch in iOS Simulator
- Intro animation will play (3 seconds)

### **Step 5: Login**
- **Email**: `hr@acemarket.com`
- **Password**: `password123`
- Click **"Sign In"**

---

## ✅ What's Fixed

### **API URL**
Changed back to `localhost` for iOS Simulator:
```dart
static const String baseUrl = 'http://localhost:8080/api/v1';
```

### **Backend**
- ✅ Fresh restart
- ✅ Database connected
- ✅ All routes registered
- ✅ CORS configured
- ✅ Login endpoint tested and working

### **Verified Working**
```bash
✅ Backend: http://localhost:8080
✅ Login API: Returns JWT token
✅ User: HR Administrator
✅ Database: Connected and populated
```

---

## 🎯 Expected Result

After login, you should see:
1. ✅ Loading spinner
2. ✅ "Signed in successfully" message
3. ✅ **HR Dashboard**
   - Welcome header
   - Stats: Total Staff: 0, Branches: 13
   - Action cards (Create Staff Profile, etc.)

---

## 🔧 If Still Not Working

### **Check Backend Logs**
Look for this line in backend terminal:
```
[GIN] 2025/11/15 - 17:XX:XX | 200 | XXms | 127.0.0.1 | POST "/api/v1/auth/login"
```

If you see `500` instead of `200`, there's a backend error.

### **Check Flutter Console**
Look for network errors in the Flutter terminal output.

### **Test Backend Manually**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"hr@acemarket.com","password":"password123"}'
```

Should return JSON with token and user data.

---

## 📋 Quick Commands

### **Restart Backend**
```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
go run main.go
```

### **Restart Flutter**
```bash
cd /Users/Gracegold/Desktop/Ace\ App/ace_mall_app
flutter run
```

### **Clean Flutter Build**
```bash
flutter clean && flutter pub get && flutter run
```

---

**Everything is ready! Just restart your Flutter app and try logging in!** 🚀
