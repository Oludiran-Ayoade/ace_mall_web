# 🔐 HR-Only Account Creation System

## Overview
The Ace Supermarket app is designed so that **ONLY HR can create employee accounts**. Regular employees cannot self-register - they can only sign in with credentials provided by HR.

---

## 🎯 Account Creation Rules

### ✅ Who Can Create Accounts:

1. **HR Administrator** (senior_admin role)
   - Can create ALL types of accounts:
     - ✅ CEO, Chairman, COO
     - ✅ HR staff
     - ✅ Branch Managers
     - ✅ Floor Managers
     - ✅ General Staff (Cashiers, Cooks, Security, etc.)

### ❌ Who CANNOT Create Accounts:

1. **CEO / Chairman / COO**
   - Can view all staff
   - Can manage operations
   - ❌ Cannot create new accounts

2. **Branch Managers**
   - Can view branch staff
   - Can manage branch operations
   - ❌ Cannot create new accounts

3. **Floor Managers**
   - Can manage their team
   - Can create rosters
   - ❌ Cannot create new accounts

4. **General Staff**
   - Can view their profile
   - Can see their schedule
   - ❌ Cannot create accounts
   - ❌ Cannot self-register

---

## 📋 HR Account Creation Process

### Step 1: HR Signs In
```
Email: hr@acemarket.com
Password: password123 (change after first login)
```

### Step 2: Navigate to Staff Management
1. Dashboard → "Add New Staff" or "Staff Management"
2. Click "Create New Employee"

### Step 3: Fill Employee Details
**Required Information:**
- Full Name
- Email Address (will be username)
- Phone Number
- Role (CEO, Branch Manager, Cashier, etc.)
- Branch (if applicable)
- Department (if applicable)
- Date of Birth
- Gender
- Home Address
- State of Origin

**Optional Information:**
- Employee ID (auto-generated if not provided)
- Salary
- Profile Picture
- Educational Qualifications
- Work Experience
- Next of Kin Details
- Guarantor Information

### Step 4: System Generates Credentials
- **Email**: As provided by HR
- **Temporary Password**: Auto-generated or set by HR
- **Employee ID**: Auto-generated unique ID

### Step 5: HR Provides Credentials to Employee
HR must securely share:
- Email address (username)
- Temporary password
- Instructions to change password on first login

---

## 🔄 Employee First Login Flow

### 1. Employee Receives Credentials from HR
```
Email: john.doe@acemarket.com
Password: TempPass123! (provided by HR)
```

### 2. Employee Signs In
- Open Ace Supermarket app
- Enter email and temporary password
- Click "Sign In"

### 3. Forced Password Change
- System detects first login
- Employee must change password
- New password must meet requirements:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one number
  - At least one special character

### 4. Complete Profile (if needed)
- Upload profile picture
- Add additional personal details
- Review and confirm information

### 5. Access Dashboard
- Employee is routed to appropriate dashboard:
  - CEO → CEO Dashboard
  - HR → HR Dashboard
  - Branch Manager → Branch Manager Dashboard
  - Floor Manager → Floor Manager Dashboard
  - General Staff → General Staff Dashboard

---

## 🚫 Self-Registration is DISABLED

### Why No Self-Registration?

1. **Security**: Prevents unauthorized access
2. **Control**: HR verifies all employees before account creation
3. **Data Integrity**: Ensures all employee data is accurate
4. **Compliance**: Meets company policy requirements
5. **Hierarchy**: Maintains proper organizational structure

### What Happens if Someone Tries to Self-Register?

- No "Sign Up" button on login page
- No registration form available
- Only "Sign In" option visible
- Error message if attempting to access signup endpoints

---

## 🧹 Clearing Dummy Data for Production

### When to Clear Dummy Data:
- ✅ After testing is complete
- ✅ Before deploying to production
- ✅ When ready to add real employees

### How to Clear Dummy Data:

**Option 1: Using SQL Script**
```bash
cd /Users/Gracegold/Desktop/Ace\ App/backend/database
PGPASSWORD=Circumspect1 psql -h localhost -p 5433 -U postgres -d aceSuperMarket -f clear_all_dummy_data.sql
```

**Option 2: Manual Database Query**
```sql
-- Connect to database
psql -h localhost -p 5433 -U postgres -d aceSuperMarket

-- Run cleanup
BEGIN;
DELETE FROM roster_assignments;
DELETE FROM rosters;
DELETE FROM reviews;
DELETE FROM notifications;
DELETE FROM users;
DELETE FROM temp_signups;
COMMIT;
```

### What Gets Deleted:
- ❌ All user accounts (CEO, HR, Branch Managers, Staff, etc.)
- ❌ All rosters and schedules
- ❌ All reviews and performance data
- ❌ All notifications
- ❌ All work experience and qualifications
- ❌ All temporary signup data

### What Stays:
- ✅ Branches (6 locations)
- ✅ Departments (6 departments)
- ✅ Roles (all role definitions)
- ✅ Sub-departments (Cinema, Saloon, etc.)
- ✅ Database schema and structure

---

## 📝 Production Deployment Checklist

### Before Going Live:

1. ✅ **Clear All Dummy Data**
   ```bash
   psql -f clear_all_dummy_data.sql
   ```

2. ✅ **Create Production HR Account**
   ```sql
   INSERT INTO users (id, email, password_hash, full_name, role_id, is_active)
   VALUES (
     uuid_generate_v4(),
     'hr@acesupermarket.com',
     '$2a$10$...',  -- Use bcrypt hash
     'HR Administrator',
     (SELECT id FROM roles WHERE name = 'Human Resource'),
     true
   );
   ```

3. ✅ **Verify HR Can Sign In**
   - Test login with production HR credentials
   - Confirm access to HR dashboard
   - Test account creation functionality

4. ✅ **Create First Real Employee**
   - HR creates CEO account
   - CEO signs in and changes password
   - Verify CEO dashboard access

5. ✅ **Document Credentials Securely**
   - Store HR credentials in secure password manager
   - Share CEO credentials securely
   - Set up password rotation policy

6. ✅ **Configure Email Service**
   - Set up production email server
   - Test password reset emails
   - Test notification emails

7. ✅ **Backup Database**
   ```bash
   pg_dump -h localhost -p 5433 -U postgres aceSuperMarket > backup_before_production.sql
   ```

---

## 🔑 Current Test Credentials (DUMMY DATA)

### Senior Admin:
- **CEO**: `ceo@acemarket.com` / `password123`
- **Chairman**: `chairman@acemarket.com` / `password123`
- **HR**: `hr@acemarket.com` / `password123`

### Branch Managers:
- **Bodija**: `bm.bodija@acemarket.com` / `password123`
- **Ogbomosho**: `bm.ogbomosho@acemarket.com` / `password123`
- **Akobo**: `bm.akobo@acemarket.com` / `password123`

### Floor Managers:
- **Lounge (Bodija)**: `fm.lg.bodija@acesupermarket.com` / `password123`
- **SuperMarket (Bodija)**: `fm.sm.bodija@acesupermarket.com` / `password123`

### General Staff:
- **Cashier**: `cashier1.akobo@acesupermarket.com` / `password123`

**⚠️ IMPORTANT**: Delete all these accounts before production!

---

## 🎯 Role-Based Dashboard Routing

The system automatically routes users to the correct dashboard based on their role:

| Role | Dashboard Route | Features |
|------|----------------|----------|
| CEO / Chairman | `/ceo-dashboard` | Staff oversight, all branches, analytics |
| HR | `/hr-dashboard` | Create accounts, manage all staff, reports |
| Branch Manager | `/branch-manager-dashboard` | Branch staff, departments, schedules |
| Floor Manager | `/floor-manager-dashboard` | Team management, rosters, reviews |
| General Staff | `/general-staff-dashboard` | Personal schedule, reviews, profile |

### How Routing Works:

1. User signs in with email/password
2. Backend returns `role_name` in login response
3. Frontend checks role_name:
   ```dart
   if (roleName.contains('CEO') || roleName.contains('Chairman')) {
     navigate to '/ceo-dashboard'
   } else if (roleName.contains('HR')) {
     navigate to '/hr-dashboard'
   } else if (roleName.contains('Branch Manager')) {
     navigate to '/branch-manager-dashboard'
   } else if (roleName.contains('Floor Manager')) {
     navigate to '/floor-manager-dashboard'
   } else {
     navigate to '/general-staff-dashboard'
   }
   ```

---

## ✅ Summary

- ✅ **ONLY HR** can create employee accounts
- ✅ Employees receive credentials from HR
- ✅ Employees sign in (not sign up)
- ✅ First login requires password change
- ✅ Automatic routing to correct dashboard
- ✅ Easy to clear dummy data for production
- ✅ Secure, controlled account management

This system ensures proper security, data integrity, and organizational hierarchy! 🎉
