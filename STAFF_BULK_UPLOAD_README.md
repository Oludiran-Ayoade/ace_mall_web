# Ace SuperMarket - Staff Bulk Upload Template Guide

## 📋 Overview
This template allows you to enter staff details in bulk for importing into the PostgreSQL database. The CSV format is compatible with Excel, Google Sheets, and direct database import.

---

## 📁 Files Provided
1. **STAFF_BULK_UPLOAD_TEMPLATE.csv** - Main data entry template with sample rows
2. **STAFF_BULK_UPLOAD_README.md** - This instruction file

---

## 🏢 Staff Categories

### 1. **Senior Admin** (No Branch/Department)
- Chief Executive Officer (CEO)
- Chief Operating Officer (COO)
- Chairman
- Human Resources Manager
- Group Head (Lounge)
- Group Head (Supermarket)
- Group Head (Fun & Arcade)
- Group Head (Compliance)
- Group Head (Facility Management)
- Auditor

### 2. **Admin** (Branch-Specific)
- Branch Manager
- Operations Manager
- Floor Manager (Lounge)
- Floor Manager (Supermarket)
- Floor Manager (Fun & Arcade)
- Floor Manager (Compliance)
- Floor Manager (Facility Management)
- Sub-Department Managers (Cinema, Photo Studio, Saloon, Arcade & Kiddies, Casino)
- Compliance Officer
- Facility Manager

### 3. **General Staff** (Branch & Department Specific)
**Supermarket:**
- Cashier, Customer Service Rep, Stocker, Warehouse Worker, Security Guard

**Lounge:**
- Bartender, Server, Hostess, Chef, Cook, Kitchen Helper, Dishwasher

**Fun & Arcade:**
- Arcade Attendant, Game Technician, Ticket Agent, Usher

**Cinema:**
- Projectionist, Ticket Sales Agent, Usher, Concession Stand Worker

**Photo Studio:**
- Photographer, Photo Editor, Studio Assistant, Receptionist

**Saloon:**
- Hair Stylist, Barber, Manicurist, Pedicurist, Receptionist, Cleaner

**Bakery:**
- Baker, Pastry Chef, Cake Decorator, Bakery Clerk

**Compliance:**
- Compliance Assistant

**Facility Management:**
- Maintenance Worker, Electrician, Plumber, Cleaner, Janitor

---

## 📝 Required Fields (51 Columns)

### Basic Information (10 fields)
1. **Staff Category** - Senior Admin / Admin / General Staff
2. **Full Name** - First and Last name
3. **Email** - Unique email address (will be username)
4. **Password** - Initial password (min 8 characters)
5. **Phone** - Format: +234XXXXXXXXXX
6. **Gender** - Male / Female / Other
7. **Date of Birth** - Format: YYYY-MM-DD (e.g., 1990-05-15)
8. **Address** - Full residential address
9. **State of Origin** - Nigerian state
10. **Employee ID** - Format: ACE-[ROLE]-[BRANCH]-[NUMBER]

### Work Information (5 fields)
11. **Date Joined** - Format: YYYY-MM-DD
12. **Role** - Exact role name from list above
13. **Department** - Supermarket/Lounge/Fun & Arcade/Compliance/Facility Management/N/A
14. **Branch** - Ace Ogbomosho/Ace Bodija/etc. (or N/A for Senior Admin)
15. **Salary** - Monthly salary in Naira (numeric only)

### Profile (1 field)
16. **Profile Picture URL** - Cloudinary URL or file path (optional)

### Education (7 fields)
17. **Educational Level** - SSCE/OND/HND/Bachelors/Masters/PhD
18. **Course/Field of Study** - Major/specialization
19. **Institution** - School/University name
20. **Grade/Class** - First Class/Second Class Upper/Lower Credit/etc.
21. **Graduation Year** - YYYY
22. **WAEC/O'Level Score** - Overall grade (A1-F9) or N/A
23. **SSCE Certificate Number** - WAE/YYYY/XXXXX or N/A

### Next of Kin (5 fields)
24. **Next of Kin Name**
25. **Next of Kin Relationship** - Parent/Spouse/Sibling/Child
26. **Next of Kin Phone**
27. **Next of Kin Email**
28. **Next of Kin Address**

### Guarantor 1 (6 fields)
29. **Guarantor 1 Name**
30. **Guarantor 1 Phone**
31. **Guarantor 1 Email**
32. **Guarantor 1 Address**
33. **Guarantor 1 Occupation**
34. **Guarantor 1 Employer**

### Guarantor 2 (6 fields)
35. **Guarantor 2 Name**
36. **Guarantor 2 Phone**
37. **Guarantor 2 Email**
38. **Guarantor 2 Address**
39. **Guarantor 2 Occupation**
40. **Guarantor 2 Employer**

### Document Paths (11 fields)
41. **Birth Certificate Path** - File path: docs/[category]/[filename].pdf
42. **Passport Photo Path** - File path: docs/[category]/[filename].jpg
43. **National ID Path** - File path: docs/[category]/[filename].pdf
44. **NYSC Certificate Path** - File path or N/A (if not applicable)
45. **Degree Certificate Path** - File path or N/A
46. **WAEC Certificate Path** - File path
47. **State of Origin Certificate Path** - File path
48. **Guarantor 1 Passport Path** - File path
49. **Guarantor 1 National ID Path** - File path
50. **Guarantor 1 Work ID Path** - File path
51. **Guarantor 2 Passport Path** - File path
52. **Guarantor 2 National ID Path** - File path
53. **Guarantor 2 Work ID Path** - File path

### Status (2 fields)
54. **Is Active** - Yes / No
55. **Notes** - Additional information (optional)

---

## 📄 Document Upload Strategy

### 1. Organize Documents
Create folder structure:
```
documents/
├── senior_admin/
│   ├── ceo/
│   ├── hr/
│   └── coo/
├── admin/
│   ├── branch_managers/
│   └── floor_managers/
└── general_staff/
    ├── cashiers/
    ├── cooks/
    └── security/
```

### 2. Upload to Cloud Storage
- **Option 1**: Cloudinary (recommended for images)
- **Option 2**: AWS S3
- **Option 3**: Google Drive (with public links)
- **Option 4**: Server local storage

### 3. Reference in CSV
Use relative paths or full URLs:
- Relative: `docs/ceo/birth_cert.pdf`
- Full URL: `https://res.cloudinary.com/ace/image/upload/v123/ceo_passport.jpg`

---

## 🔢 Employee ID Format

### Senior Admin
- `ACE-CEO-001` (Chief Executive Officer)
- `ACE-HR-001` (Human Resources Manager)
- `ACE-COO-001` (Chief Operating Officer)
- `ACE-GH-LNG-001` (Group Head Lounge)

### Admin
- `ACE-BM-OGB-001` (Branch Manager - Ogbomosho)
- `ACE-FM-LNG-BOD-001` (Floor Manager Lounge - Bodija)

### General Staff
- `ACE-CSH-AKO-001` (Cashier - Akobo)
- `ACE-CK-LNG-OGB-001` (Cook Lounge - Ogbomosho)
- `ACE-SEC-BOD-001` (Security - Bodija)

---

## 📊 How to Fill the Template

### Step 1: Open in Excel/Google Sheets
1. Open `STAFF_BULK_UPLOAD_TEMPLATE.csv` in Excel or Google Sheets
2. Review the sample data rows (rows 2-8)
3. Understand each column's purpose

### Step 2: Add Your Staff Data
1. Delete sample rows or keep as reference
2. Add one row per staff member
3. Fill all required columns (don't leave empty unless specified as optional)
4. Use consistent date format: YYYY-MM-DD
5. Use consistent phone format: +234XXXXXXXXXX

### Step 3: Data Validation
Check for:
- ✅ Unique emails (no duplicates)
- ✅ Unique employee IDs
- ✅ Valid date formats
- ✅ Correct staff category for role
- ✅ Branch/Department match for role type
- ✅ All document paths are valid

### Step 4: Export to CSV
1. **Excel**: File → Save As → CSV (Comma delimited)
2. **Google Sheets**: File → Download → Comma Separated Values (.csv)

---

## 🗄️ PostgreSQL Import Steps

### Option 1: Direct CSV Import (Recommended)

```sql
-- 1. Create temporary table
CREATE TEMP TABLE temp_staff_import (
    staff_category VARCHAR(50),
    full_name VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    phone VARCHAR(20),
    gender VARCHAR(20),
    dob DATE,
    address TEXT,
    state_of_origin VARCHAR(100),
    employee_id VARCHAR(50),
    date_joined DATE,
    role VARCHAR(255),
    department VARCHAR(100),
    branch VARCHAR(100),
    salary DECIMAL(15,2),
    profile_picture TEXT,
    education_level VARCHAR(50),
    course VARCHAR(255),
    institution VARCHAR(255),
    grade VARCHAR(100),
    graduation_year INTEGER,
    waec_score VARCHAR(10),
    ssce_number VARCHAR(50),
    nok_name VARCHAR(255),
    nok_relationship VARCHAR(50),
    nok_phone VARCHAR(20),
    nok_email VARCHAR(255),
    nok_address TEXT,
    g1_name VARCHAR(255),
    g1_phone VARCHAR(20),
    g1_email VARCHAR(255),
    g1_address TEXT,
    g1_occupation VARCHAR(255),
    g1_employer VARCHAR(255),
    g2_name VARCHAR(255),
    g2_phone VARCHAR(20),
    g2_email VARCHAR(255),
    g2_address TEXT,
    g2_occupation VARCHAR(255),
    g2_employer VARCHAR(255),
    birth_cert_path TEXT,
    passport_path TEXT,
    national_id_path TEXT,
    nysc_path TEXT,
    degree_path TEXT,
    waec_path TEXT,
    state_origin_path TEXT,
    g1_passport_path TEXT,
    g1_id_path TEXT,
    g1_work_id_path TEXT,
    g2_passport_path TEXT,
    g2_id_path TEXT,
    g2_work_id_path TEXT,
    is_active VARCHAR(10),
    notes TEXT
);

-- 2. Import CSV file
\COPY temp_staff_import FROM '/path/to/STAFF_BULK_UPLOAD_TEMPLATE.csv' WITH CSV HEADER;

-- 3. Insert into users table (with password hashing)
INSERT INTO users (
    full_name, email, password_hash, phone, gender, dob, 
    address, state_of_origin, employee_id, date_joined,
    role_id, department_id, branch_id, salary, profile_picture,
    is_active, created_at, updated_at
)
SELECT 
    full_name,
    email,
    crypt(password, gen_salt('bf')), -- Hash password with bcrypt
    phone,
    gender,
    dob,
    address,
    state_of_origin,
    employee_id,
    date_joined,
    (SELECT id FROM roles WHERE name = role LIMIT 1),
    (SELECT id FROM departments WHERE name = department LIMIT 1),
    (SELECT id FROM branches WHERE name = branch LIMIT 1),
    salary,
    profile_picture,
    CASE WHEN LOWER(is_active) = 'yes' THEN true ELSE false END,
    NOW(),
    NOW()
FROM temp_staff_import;

-- 4. Insert education records
INSERT INTO qualifications (
    user_id, qualification_type, course, institution, 
    grade, year, created_at, updated_at
)
SELECT 
    u.id,
    t.education_level,
    t.course,
    t.institution,
    t.grade,
    t.graduation_year,
    NOW(),
    NOW()
FROM temp_staff_import t
JOIN users u ON u.email = t.email
WHERE t.education_level IS NOT NULL;

-- 5. Insert next of kin
INSERT INTO next_of_kin (
    user_id, name, relationship, phone, email, address,
    created_at, updated_at
)
SELECT 
    u.id,
    t.nok_name,
    t.nok_relationship,
    t.nok_phone,
    t.nok_email,
    t.nok_address,
    NOW(),
    NOW()
FROM temp_staff_import t
JOIN users u ON u.email = t.email;

-- 6. Insert guarantors
-- (Add similar INSERT statements for guarantors table)

-- 7. Clean up
DROP TABLE temp_staff_import;
```

### Option 2: Using Backend API
Create a bulk upload endpoint in your Go backend:
```go
POST /api/v1/staff/bulk-upload
Content-Type: multipart/form-data
```

---

## ✅ Validation Checklist

Before importing, verify:

- [ ] All emails are unique and valid format
- [ ] All employee IDs are unique and follow format
- [ ] Passwords meet minimum requirements (8+ characters)
- [ ] Phone numbers include country code
- [ ] Dates are in YYYY-MM-DD format
- [ ] Staff categories match role types
- [ ] Branches exist in database for Admin/General Staff
- [ ] Departments exist in database
- [ ] Roles exist in roles table
- [ ] Document paths are accessible
- [ ] Salary values are numeric
- [ ] All required fields are filled

---

## 🔧 Tips & Best Practices

1. **Start Small**: Test with 5-10 staff first
2. **Backup**: Always backup database before bulk import
3. **Validate**: Use Excel formulas to validate data
4. **Consistency**: Use dropdown lists for categories, gender, etc.
5. **Document Naming**: Use consistent naming: `[category]_[name]_[doctype].pdf`
6. **Password Security**: Change passwords after first login
7. **Phone Format**: Always include +234 country code
8. **Date Format**: Never use 01/05/2020 (ambiguous), use 2020-05-01

---

## 📞 Support

For questions or issues:
- Email: hr@acesupermarket.com
- Review the sample data rows in the CSV
- Check database schema in `/backend/database/schema.sql`

---

## 🔄 Update Workflow

1. **Add new staff** → Fill CSV template
2. **Upload documents** → Organize in folders, upload to cloud
3. **Export CSV** → Save as .csv format
4. **Validate data** → Check all fields
5. **Import to DB** → Run SQL import script
6. **Verify** → Test login with sample accounts
7. **Notify staff** → Send welcome emails with credentials

---

**Last Updated**: January 8, 2026
**Version**: 1.0
