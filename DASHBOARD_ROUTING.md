# 🎯 Dashboard Routing Guide

## Role-Based Dashboard Access

The application now routes users to different dashboards based on their role:

### 📊 Dashboard Mapping

| Role | Dashboard | Route | Color Theme |
|------|-----------|-------|-------------|
| **CEO** | CEO Dashboard | `/ceo-dashboard` | Green Gradient |
| **Chairman** | CEO Dashboard | `/ceo-dashboard` | Green Gradient |
| **HR / Human Resource** | HR Dashboard | `/hr-dashboard` | Green |
| **Branch Manager** | Branch Manager Dashboard | `/branch-manager-dashboard` | Blue Gradient |
| **Floor Manager** | HR Dashboard* | `/hr-dashboard` | Green |
| **General Staff** | HR Dashboard* | `/hr-dashboard` | Green |

*Floor Manager and General Staff dashboards coming soon

---

## 🎨 Dashboard Features

### CEO Dashboard
- **Header:** "Welcome, CEO" with business icon
- **Stats:** Total Staff, Branches, Departments, Active Staff
- **Actions:**
  - View All Staff
  - Departments Overview
  - Reports & Analytics
  - Staff Promotions
  - Branch Performance

### HR Dashboard
- **Header:** "Welcome, HR Admin"
- **Stats:** Total Staff, Branches
- **Actions:**
  - Create Staff Profile
  - View All Staff
  - Manage Departments
  - Promote Staff
  - Reports & Analytics

### Branch Manager Dashboard
- **Header:** "Welcome, Branch Manager" with store icon
- **Stats:** Branch Staff, Departments, Active, On Duty
- **Actions:**
  - Branch Staff
  - Departments
  - Rosters & Schedules
  - Branch Reports
  - Staff Performance

---

## ✅ Tested Login Credentials

All accounts use password: **`password123`**

### CEO
- Email: `ceo@acemarket.com`
- Routes to: CEO Dashboard ✅

### HR
- Email: `hr@acemarket.com`
- Routes to: HR Dashboard ✅

### Branch Managers
- Email: `bm.bodija@acemarket.com`
- Routes to: Branch Manager Dashboard ✅

### Other Branch Managers
- `bm.ogbomosho@acemarket.com`
- `bm.akobo@acemarket.com`
- `bm.oluyole@acemarket.com`
- `bm.oyo@acemarket.com`

All route to: Branch Manager Dashboard ✅

---

## 🔧 Implementation Details

### Routing Logic (`signin_page.dart`)
```dart
if (roleName.contains('CEO') || roleName.contains('Chief Executive')) {
  dashboardRoute = '/ceo-dashboard';
} else if (roleName.contains('Chairman')) {
  dashboardRoute = '/ceo-dashboard';
} else if (roleName.contains('HR') || roleName.contains('Human Resource')) {
  dashboardRoute = '/hr-dashboard';
} else if (roleName.contains('Branch Manager')) {
  dashboardRoute = '/branch-manager-dashboard';
}
```

### Backend Role Names
- CEO: `"Chief Executive Officer"`
- HR: `"Human Resource"`
- Branch Manager: `"Branch Manager (SuperMarket)"`
- Floor Manager: `"Floor Manager (SuperMarket)"`, `"Floor Manager (Lounge)"`, etc.

---

## 🚀 Next Steps

To test:
1. **Hot reload** your Flutter app (press `r` in terminal)
2. **Sign out** if currently logged in
3. **Sign in** with any of the test accounts
4. **Verify** you're routed to the correct dashboard

Each dashboard has a unique design and features tailored to that role!
