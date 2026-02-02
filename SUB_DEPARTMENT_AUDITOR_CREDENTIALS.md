# 🔑 Sub-Department Managers & Auditor Login Credentials

## ✅ Updated Routing Logic

**Sub-Department Managers now use Floor Manager Dashboard (100% identical functionality)**

---

## 🎭 SUB-DEPARTMENT MANAGERS

### **These roles use the FLOOR MANAGER DASHBOARD:**
- Cinema Manager
- Photo Studio Manager
- Saloon Manager
- Arcade Manager
- Casino Manager

### **Dashboard Features:**
- ✅ Create General Staff in their department
- ✅ Manage team roster
- ✅ Review staff performance
- ✅ Customize shift times
- ✅ View team members
- ✅ Weekly reviews

---

## 🔮 AUDITORS

### **Auditors use the AUDITOR DASHBOARD:**
- Purple-themed dashboard
- 100% identical to COO Dashboard structure
- Compliance & Oversight focus

---

## 🔐 TEST CREDENTIALS

### **1. AUDITORS** 🔮

**Universal Password:** `password123`

| Email | Name | Role | Dashboard |
|-------|------|------|-----------|
| `auditor@acesupermarket.com` | Mr. Tunde Bakare | Auditor | Auditor Dashboard (Purple) |
| `auditor2@acesupermarket.com` | Mrs. Ngozi Okafor | Auditor | Auditor Dashboard (Purple) |

**Features:**
- ✅ View all 13 branches
- ✅ Access branch reports
- ✅ Monitor compliance
- ✅ View all staff
- ✅ Check rosters
- ✅ Review analytics

---

### **2. SUB-DEPARTMENT MANAGERS** 🎭

**Note:** These accounts need to be created in the database. Below are suggested credentials:

#### **Cinema Managers**

| Email | Name | Branch | Dashboard |
|-------|------|--------|-----------|
| `cinema.abeokuta@acesupermarket.com` | Mr. Tayo Adeyemi | Ace Mall, Abeokuta | Floor Manager |
| `cinema.bodija@acesupermarket.com` | Miss Funke Oladele | Ace Mall, Bodija | Floor Manager |
| `cinema.akobo@acesupermarket.com` | Mr. Segun Afolabi | Ace Mall, Akobo | Floor Manager |

#### **Photo Studio Managers**

| Email | Name | Branch | Dashboard |
|-------|------|--------|-----------|
| `photostudio.abeokuta@acesupermarket.com` | Mrs. Kemi Adebayo | Ace Mall, Abeokuta | Floor Manager |
| `photostudio.bodija@acesupermarket.com` | Mr. Wale Ogunbiyi | Ace Mall, Bodija | Floor Manager |
| `photostudio.akobo@acesupermarket.com` | Miss Shade Akinola | Ace Mall, Akobo | Floor Manager |

#### **Saloon Managers**

| Email | Name | Branch | Dashboard |
|-------|------|--------|-----------|
| `saloon.abeokuta@acesupermarket.com` | Miss Blessing Okoro | Ace Mall, Abeokuta | Floor Manager |
| `saloon.bodija@acesupermarket.com` | Mr. Gbenga Fashola | Ace Mall, Bodija | Floor Manager |
| `saloon.akobo@acesupermarket.com` | Mrs. Yetunde Olatunji | Ace Mall, Akobo | Floor Manager |

#### **Arcade Managers**

| Email | Name | Branch | Dashboard |
|-------|------|--------|-----------|
| `arcade.abeokuta@acesupermarket.com` | Mr. Kunle Adeleke | Ace Mall, Abeokuta | Floor Manager |
| `arcade.bodija@acesupermarket.com` | Miss Zainab Ibrahim | Ace Mall, Bodija | Floor Manager |
| `arcade.akobo@acesupermarket.com` | Mr. Biodun Alabi | Ace Mall, Akobo | Floor Manager |

#### **Casino Managers**

| Email | Name | Branch | Dashboard |
|-------|------|--------|-----------|
| `casino.abeokuta@acesupermarket.com` | Mr. Chidi Okonkwo | Ace Mall, Abeokuta | Floor Manager |
| `casino.bodija@acesupermarket.com` | Mrs. Amaka Nwosu | Ace Mall, Bodija | Floor Manager |
| `casino.akobo@acesupermarket.com` | Mr. Lanre Adebisi | Ace Mall, Akobo | Floor Manager |

**Universal Password:** `password123`

---

## 🚀 QUICK TEST GUIDE

### **Test Auditor Dashboard:**

```
1. Login Credentials:
   Email: auditor@acesupermarket.com
   Password: password123

2. Expected Result:
   ✅ Purple-themed Auditor Dashboard
   ✅ "Auditor Dashboard" title
   ✅ "Compliance & Oversight" subtitle
   ✅ View all 13 branches
   ✅ Access branch reports
   ✅ Operations tools

3. Test Flow:
   Sign In → Purple Loading → Auditor Dashboard → Click Branch → Branch Report
```

---

### **Test Sub-Department Manager Dashboard:**

```
1. Login Credentials (Example):
   Email: cinema.abeokuta@acesupermarket.com
   Password: password123

2. Expected Result:
   ✅ Floor Manager Dashboard (same as regular floor managers)
   ✅ Create General Staff button
   ✅ Manage Roster
   ✅ My Team (for reviews)
   ✅ Shift Times
   ✅ View team members

3. Test Flow:
   Sign In → Loading → Floor Manager Dashboard → Create Staff / Manage Roster
```

---

## 📊 DASHBOARD COMPARISON

| Role | Dashboard | Color | Features |
|------|-----------|-------|----------|
| **Auditor** | Auditor Dashboard | Purple | Branch reports, compliance, oversight |
| **Cinema Manager** | Floor Manager | Green | Team management, roster, reviews |
| **Photo Studio Manager** | Floor Manager | Green | Team management, roster, reviews |
| **Saloon Manager** | Floor Manager | Green | Team management, roster, reviews |
| **Arcade Manager** | Floor Manager | Green | Team management, roster, reviews |
| **Casino Manager** | Floor Manager | Green | Team management, roster, reviews |
| **Floor Manager** | Floor Manager | Green | Team management, roster, reviews |

---

## ✅ ROUTING LOGIC UPDATED

### **signin_page.dart Changes:**

```dart
// Auditors → Auditor Dashboard
else if (roleName.contains('Auditor')) {
  dashboardRoute = '/auditor-dashboard';
}

// Sub-Department Managers → Floor Manager Dashboard
else if (roleName.contains('Floor Manager') || 
         roleName.contains('Cinema Manager') ||
         roleName.contains('Photo Studio Manager') ||
         roleName.contains('Saloon Manager') ||
         roleName.contains('Arcade Manager') ||
         roleName.contains('Casino Manager')) {
  dashboardRoute = '/floor-manager-dashboard';
}
```

---

## 🎯 WHAT EACH ROLE CAN DO

### **Auditors:**
- ✅ View all branches and staff
- ✅ Access branch reports with detailed stats
- ✅ Monitor compliance across organization
- ✅ View rosters and ratings
- ✅ Access reports & analytics
- ✅ Staff oversight

### **Sub-Department Managers (Cinema, Photo Studio, Saloon, Arcade, Casino):**
- ✅ Create General Staff in their sub-department
- ✅ Manage weekly rosters
- ✅ Review team performance (5-star ratings)
- ✅ Customize shift times
- ✅ View team members
- ✅ Track attendance
- ✅ Same permissions as Floor Managers

---

## 📝 DATABASE SETUP NEEDED

**To create Sub-Department Manager accounts, run SQL:**

```sql
-- Example for Cinema Manager at Abeokuta
INSERT INTO users (
  email, 
  password_hash, 
  full_name, 
  role_name, 
  role_category,
  department_id,
  branch_id,
  date_joined
) VALUES (
  'cinema.abeokuta@acesupermarket.com',
  '$2a$10$YourBcryptHashHere', -- bcrypt hash of 'password123'
  'Mr. Tayo Adeyemi',
  'Cinema Manager',
  'admin',
  (SELECT id FROM departments WHERE name = 'Cinema'),
  (SELECT id FROM branches WHERE name = 'Ace Mall, Abeokuta'),
  CURRENT_DATE
);
```

**Repeat for all sub-department managers across branches.**

---

## 🎊 SUMMARY

### **Auditors:**
- ✅ **2 existing accounts** ready to test
- ✅ **Purple Auditor Dashboard** implemented
- ✅ **Routing updated** to `/auditor-dashboard`
- ✅ **100% identical to COO Dashboard** (purple theme)

### **Sub-Department Managers:**
- ✅ **Routing updated** to use Floor Manager Dashboard
- ✅ **100% identical functionality** to Floor Managers
- ✅ **Accounts need creation** in database
- ✅ **Suggested credentials** provided above

---

## 🔐 READY TO TEST NOW

### **Auditor (Works Immediately):**
```
Email: auditor@acesupermarket.com
Password: password123
Dashboard: Purple Auditor Dashboard ✅
```

### **Sub-Department Managers (Need DB Setup):**
```
Email: cinema.abeokuta@acesupermarket.com (example)
Password: password123
Dashboard: Floor Manager Dashboard ✅
```

---

**Last Updated:** December 5, 2025  
**Status:** ✅ Routing Complete, Auditors Ready, Sub-Dept Managers Need DB Setup
