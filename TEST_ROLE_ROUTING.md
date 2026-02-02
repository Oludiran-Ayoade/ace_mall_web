# 🧪 Role-Based Routing Test Results

## ✅ Backend Login API Tests

### Test 1: HR Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"hr@acemarket.com","password":"password123"}'
```

**Expected Result:**
```json
{
  "role_name": "Human Resource",
  "user": {
    "full_name": "HR Administrator",
    "email": "hr@acemarket.com"
  },
  "token": "eyJ..."
}
```

**Frontend Routing:** → `/hr-dashboard` ✅

---

### Test 2: CEO Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"ceo@acemarket.com","password":"password123"}'
```

**Expected Result:**
```json
{
  "role_name": "Chief Executive Officer",
  "user": {
    "full_name": "Mr. Adeyemi Fashola",
    "email": "ceo@acemarket.com"
  },
  "token": "eyJ..."
}
```

**Frontend Routing:** → `/ceo-dashboard` ✅

---

### Test 3: Chairman Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"chairman@acemarket.com","password":"password123"}'
```

**Expected Result:**
```json
{
  "role_name": "Chairman",
  "user": {
    "full_name": "Chief Akinwale",
    "email": "chairman@acemarket.com"
  },
  "token": "eyJ..."
}
```

**Frontend Routing:** → `/ceo-dashboard` ✅ (Chairman uses CEO dashboard)

---

### Test 4: Branch Manager Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"bm.bodija@acemarket.com","password":"password123"}'
```

**Expected Result:**
```json
{
  "role_name": "Branch Manager (SuperMarket)",
  "user": {
    "full_name": "Mrs. Blessing Okonkwo",
    "email": "bm.bodija@acemarket.com"
  },
  "token": "eyJ..."
}
```

**Frontend Routing:** → `/branch-manager-dashboard` ✅

---

### Test 5: Floor Manager Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"fm.lg.bodija@acesupermarket.com","password":"password123"}'
```

**Expected Result:**
```json
{
  "role_name": "Floor Manager (Lounge)",
  "user": {
    "full_name": "Mr. Chidi Okonkwo",
    "email": "fm.lg.bodija@acesupermarket.com"
  },
  "token": "eyJ..."
}
```

**Frontend Routing:** → `/floor-manager-dashboard` ✅

---

### Test 6: General Staff (Cashier) Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"cashier1.akobo@acesupermarket.com","password":"password123"}'
```

**Expected Result:**
```json
{
  "role_name": "Cashier",
  "user": {
    "full_name": "Biodun Alabi",
    "email": "cashier1.akobo@acesupermarket.com"
  },
  "token": "eyJ..."
}
```

**Frontend Routing:** → `/general-staff-dashboard` ✅

---

## 📱 Flutter Frontend Routing Logic

Located in: `lib/pages/signin_page.dart`

```dart
// Navigate to appropriate dashboard based on role
String dashboardRoute = '/hr-dashboard'; // Default

if (roleName != null) {
  if (roleName.contains('CEO') || roleName.contains('Chief Executive')) {
    dashboardRoute = '/ceo-dashboard';
  } else if (roleName.contains('Chairman')) {
    dashboardRoute = '/ceo-dashboard'; // Chairman uses CEO dashboard
  } else if (roleName.contains('HR') || roleName.contains('Human Resource')) {
    dashboardRoute = '/hr-dashboard';
  } else if (roleName.contains('Branch Manager')) {
    dashboardRoute = '/branch-manager-dashboard';
  } else if (roleName.contains('Floor Manager')) {
    dashboardRoute = '/floor-manager-dashboard';
  } else {
    // General staff
    dashboardRoute = '/general-staff-dashboard';
  }
}

Navigator.of(context).pushReplacementNamed(dashboardRoute);
```

---

## ✅ Test Checklist

### Backend Tests:
- [x] HR login returns `role_name: "Human Resource"`
- [x] CEO login returns `role_name: "Chief Executive Officer"`
- [x] Chairman login returns `role_name: "Chairman"`
- [x] Branch Manager login returns `role_name: "Branch Manager (...)"`
- [x] Floor Manager login returns `role_name: "Floor Manager (...)"`
- [x] General Staff login returns specific role name

### Frontend Tests:
- [ ] HR → Routes to HR Dashboard
- [ ] CEO → Routes to CEO Dashboard
- [ ] Chairman → Routes to CEO Dashboard
- [ ] Branch Manager → Routes to Branch Manager Dashboard
- [ ] Floor Manager → Routes to Floor Manager Dashboard
- [ ] General Staff → Routes to General Staff Dashboard

---

## 🐛 Common Issues & Fixes

### Issue 1: User routes to wrong dashboard
**Cause:** `role_name` is null or doesn't match routing logic
**Fix:** Check backend returns `role_name` in login response

### Issue 2: All users route to HR dashboard
**Cause:** Default fallback when role_name is null
**Fix:** Ensure backend query includes `r.name as role_name`

### Issue 3: Branch Manager routes to HR dashboard
**Cause:** Role name doesn't contain "Branch Manager"
**Fix:** Check exact role name in database matches routing logic

---

## 🚀 How to Test

1. **Restart Backend** (to pick up auth.go changes)
   ```bash
   cd backend
   go run main.go
   ```

2. **Restart Flutter App** (full restart, not hot reload)
   - Press `q` to quit
   - Run `flutter run` again
   - Or press `R` (capital R) for full restart

3. **Test Each Role:**
   - Sign in as HR → Should see HR Dashboard
   - Sign out → Sign in as CEO → Should see CEO Dashboard
   - Sign out → Sign in as Branch Manager → Should see Branch Manager Dashboard
   - etc.

4. **Verify Console Output:**
   ```
   🔐 Login successful!
   📋 Role: Branch Manager (SuperMarket)
   🚀 Navigating to: /branch-manager-dashboard
   ```

---

## ✅ Status

- ✅ Backend returns `role_name` correctly
- ✅ Frontend routing logic implemented
- ⏳ Waiting for full Flutter restart to test
- ⏳ All dashboards need to be created/verified

**Next Step:** Full restart Flutter app and test each role login!
