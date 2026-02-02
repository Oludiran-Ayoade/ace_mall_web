# Floor Manager Staff Creation Feature

## ✅ Implementation Complete

Floor Managers can now create staff accounts for their department members!

---

## 🎯 Feature Overview

**Who**: Floor Managers only  
**What**: Create General Staff accounts  
**Where**: Their own department and branch only  
**Restrictions**: Cannot create Admin or Senior Admin roles

---

## 📋 Implementation Details

### **1. Frontend - Floor Manager Dashboard**

**File**: `/ace_mall_app/lib/pages/floor_manager_dashboard_page.dart`

**Added Card**:
```dart
'Add Team Member'
- Icon: person_add
- Color: Purple (#9C27B0)
- Action: Navigate to /floor-manager-add-staff
```

### **2. Frontend - Staff Creation Page**

**File**: `/ace_mall_app/lib/pages/floor_manager_add_staff_page.dart`

**Features**:
- ✅ Auto-fills department and branch from Floor Manager's profile
- ✅ Shows only General Staff roles for their department
- ✅ Form validation for all fields
- ✅ Password visibility toggle
- ✅ Beautiful purple-themed UI matching Floor Manager dashboard

**Form Fields**:
1. **Full Name** - Required
2. **Email Address** - Required, validated
3. **Phone Number** - Required
4. **Role** - Dropdown (General Staff roles only)
5. **Initial Password** - Required, min 6 characters

**Auto-filled** (from Floor Manager's profile):
- Department
- Branch

### **3. Frontend - API Service**

**File**: `/ace_mall_app/lib/services/api_service.dart`

**New Method**:
```dart
Future<Map<String, dynamic>> createStaffByFloorManager({
  required String fullName,
  required String email,
  required String phone,
  required String password,
  required String roleId,
  required String departmentId,
  required String branchId,
})
```

**Endpoint**: `POST /api/v1/floor-manager/create-staff`

### **4. Backend - Handler**

**File**: `/backend/handlers/floor_manager.go`

**Function**: `CreateStaffByFloorManager()`

**Security Checks**:
1. ✅ Verify user is Floor Manager (admin category)
2. ✅ Verify department matches Floor Manager's department
3. ✅ Verify branch matches Floor Manager's branch
4. ✅ Verify role is General Staff (not admin)
5. ✅ Check email doesn't already exist

**Process**:
1. Get Floor Manager's department and branch
2. Validate request data
3. Verify permissions
4. Hash password
5. Generate employee ID (ACE + timestamp)
6. Create user in database
7. Set manager_id to Floor Manager's ID
8. Return created user details

### **5. Backend - Route**

**File**: `/backend/main.go`

**Route**: `POST /api/v1/floor-manager/create-staff`  
**Handler**: `handlers.CreateStaffByFloorManager`  
**Auth**: Required (JWT token)

---

## 🔐 Security & Permissions

### **Floor Manager Can**:
- ✅ Create General Staff in their department
- ✅ Create staff in their branch only
- ✅ Set initial password for new staff
- ✅ View created staff in "My Team"

### **Floor Manager Cannot**:
- ❌ Create staff in other departments
- ❌ Create staff in other branches
- ❌ Create Admin roles (Branch Manager, Floor Manager)
- ❌ Create Senior Admin roles (CEO, HR, Chairman)
- ❌ Use email that already exists

---

## 📊 Account Creation Hierarchy

```
HR (Senior Admin)
├─ Can create: CEO, Chairman, HR, Branch Managers, Floor Managers, General Staff
├─ Scope: All branches, all departments
└─ Access: HR Dashboard → "Create Staff Profile"

Floor Manager (Admin)
├─ Can create: General Staff only
├─ Scope: Their department and branch only
└─ Access: Floor Manager Dashboard → "Add Team Member"

General Staff
├─ Can create: Nobody
└─ Access: View only their own profile
```

---

## 🎨 User Experience

### **Floor Manager Flow**:

1. **Login** as Floor Manager
2. **Dashboard** → Click "Add Team Member" card
3. **Form** → See department/branch auto-filled
4. **Fill Details**:
   - Enter staff name, email, phone
   - Select role (only General Staff roles shown)
   - Set initial password
5. **Submit** → Staff account created
6. **Success** → Redirected to dashboard
7. **Email** → Staff receives login credentials (future feature)

### **Created Staff Flow**:

1. **Receives** email with credentials (future)
2. **First Login** → Required to change password (future)
3. **Profile Completion** → Fill in personal details (future)
4. **Dashboard Access** → General Staff Dashboard

---

## 📝 Database Structure

**New Staff Record**:
```sql
- id: UUID
- email: Unique email address
- password_hash: Bcrypt hashed password
- full_name: Staff full name
- phone: Phone number
- role_id: General Staff role ID
- department_id: Floor Manager's department
- branch_id: Floor Manager's branch
- employee_id: ACE + timestamp
- manager_id: Floor Manager's user ID
- is_active: true
- is_terminated: false
- date_joined: Current timestamp
```

---

## ✅ Testing Checklist

- [x] Floor Manager dashboard shows "Add Team Member" card
- [x] Navigation to staff creation page works
- [x] Department and branch auto-fill from Floor Manager profile
- [x] Only General Staff roles shown in dropdown
- [x] Form validation works for all fields
- [x] Password visibility toggle works
- [x] Backend verifies Floor Manager permissions
- [x] Backend blocks creation in other departments
- [x] Backend blocks creation of Admin roles
- [x] Backend checks for duplicate emails
- [x] Staff created successfully with manager_id set
- [x] Success message shown and redirect to dashboard

---

## 🚀 How to Test

### **Login as Floor Manager**:
```
Email: floormanager@acemarket.com
Password: password
```

### **Test Staff Creation**:
1. Click "Add Team Member" card
2. Fill in form:
   - Name: Test Staff
   - Email: teststaff@acemarket.com
   - Phone: 08012345678
   - Role: Select from dropdown (e.g., Cashier)
   - Password: test123
3. Click "Create Staff Member"
4. Should see success message
5. Staff should appear in "My Team"

### **Test Security**:
- Try creating staff with existing email → Should fail
- Verify only General Staff roles available
- Verify department/branch cannot be changed

---

## 📌 Future Enhancements

- [ ] Email notification to new staff with credentials
- [ ] Force password change on first login
- [ ] Profile completion wizard after first login
- [ ] Bulk staff creation (CSV upload)
- [ ] Staff invitation system (staff completes own profile)

---

## 🎯 Summary

Floor Managers now have complete control over their team composition. They can:
- ✅ Add new team members independently
- ✅ Set initial credentials
- ✅ Maintain team hierarchy
- ✅ Only within their department/branch scope

This empowers Floor Managers while maintaining security through proper role-based access control!
