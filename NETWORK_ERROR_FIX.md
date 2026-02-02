# Network Error Fix Guide

## ✅ Changes Made

### 1. Search Button Color Fixed
- ✅ Changed "Search Staff" button from blue to green (#4CAF50)
- ✅ Matches the overall green theme

### 2. Enhanced Error Logging
- ✅ Added detailed console logging to track API calls
- ✅ Shows token availability status
- ✅ Shows response codes and error messages

## 🔍 Network Error Diagnosis

The network errors you're seeing are likely due to **missing authentication token**.

### Why This Happens:
1. **Not Logged In** - You might have navigated to HR dashboard without logging in
2. **Token Not Saved** - Login might have failed silently
3. **Token Expired** - Token might have expired (though unlikely immediately)

### How to Fix:

#### Step 1: Check Console Logs
After hot restart, watch the console for these messages:

**When loading staff:**
```
🔄 Loading staff data...
👥 Fetching all staff from: http://localhost:8080/api/v1/hr/staff?
🔑 Token available: Yes/No  ← THIS IS KEY!
📡 Staff response: 200
✅ Staff loaded: 152 members
```

**If you see:**
```
🔑 Token available: No
```
**Then the problem is: You're not logged in!**

#### Step 2: Proper Login Flow

**DO THIS:**
1. **Stop the app** completely (not just hot restart)
2. **Run the app fresh**
3. **Login with HR credentials:**
   - Email: `hr@acemarket.com`
   - Password: `password123`
4. **Watch console for:**
   ```
   ✅ Login successful! Token received.
   💾 Token saved successfully
   ```
5. **Then navigate to HR Dashboard**
6. **Now try the three features**

#### Step 3: Verify Backend is Running

```bash
# Check if backend is running
curl http://localhost:8080/health

# Should return:
{"status":"ok","message":"Ace Mall Staff Management API is running"}
```

If backend is not running:
```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend
go run main.go
```

## 🐛 Common Issues & Solutions

### Issue 1: "Token available: No"
**Solution:** You're not logged in. Follow Step 2 above.

### Issue 2: "Failed to connect to localhost"
**Solution:** Backend server is not running. Start it with `go run main.go`

### Issue 3: "401 Unauthorized"
**Solution:** Token is invalid or expired. Logout and login again.

### Issue 4: "Network error: SocketException"
**Solution:** 
- For iOS Simulator: Use `http://localhost:8080`
- For Android Emulator: Use `http://10.0.2.2:8080`
- For Physical Device: Use your computer's IP (e.g., `http://192.168.1.100:8080`)

## 📱 Current API Base URL

Check your `api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8080/api/v1';
```

This works for **iOS Simulator only**.

### For Android Emulator:
```dart
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
```

### For Physical Device:
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:8080/api/v1';
```

## 🧪 Test the Backend Directly

```bash
# 1. Login and get token
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"hr@acemarket.com","password":"password123"}'

# Copy the token from response

# 2. Test staff stats endpoint
curl -X GET http://localhost:8080/api/v1/hr/stats \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Should return:
{
  "total_staff": 152,
  "by_category": {...},
  "by_branch": [...]
}

# 3. Test all staff endpoint
curl -X GET http://localhost:8080/api/v1/hr/staff \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Should return:
{
  "staff": [...152 staff members...],
  "count": 152
}
```

## ✅ What Should Work After Fix

1. **Hot Restart** Flutter app (Press `R`)
2. **Login as HR** with correct credentials
3. **Check console** - should see "Token saved successfully"
4. **Navigate to HR Dashboard** - should see 152 staff count
5. **Click "View All Staff"** - should load 152 staff members
6. **Click "Manage Departments"** - should load 6 departments
7. **Click "Promote Staff"** - should load staff list

## 🎨 UI Changes Applied

- ✅ Promotion page: Purple → Green
- ✅ Search button: Blue → Green
- ✅ All buttons: Consistent green theme (#4CAF50)
- ✅ Error messages: Red background with retry button

## 📝 Next Steps

1. **Hot restart** the app
2. **Login fresh** (don't skip this!)
3. **Watch console logs** to see what's happening
4. **Report back** with the console output if still failing

The most likely issue is that you're navigating to HR dashboard without actually logging in through the signin page. The token is only saved during the login process.

**Key Point:** The backend is working perfectly (tested with curl). The issue is in the Flutter app not having/sending the authentication token.
