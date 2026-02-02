# Staff Bulk Upload Guide

## Overview
This guide explains how to mass upload staff details using CSV files instead of entering them one by one.

---

## ✅ Features Implemented

### 1. **Staff Termination System**
- **Terminate Button**: HR can click a button on any staff profile to terminate them
- **Confirmation Modal**: Shows termination type (Terminated/Resigned/Retired/Contract Ended), reason, and last working day
- **Account Suspension**: Terminated staff cannot log in unless their account is restored
- **Departed Staff Table**: All terminated staff are moved to `terminated_staff` table with full history

### 2. **Role-Based Access Control**
- **Full Access (HR/CEO/COO)**: Can view personal info, documents, next of kin, and guarantors
- **Basic Access (Auditors/Group Heads/Branch Managers/Floor Managers)**: Can only view personal info (no sensitive documents or guarantor details)
- **Frontend Tabs**: Dynamically hidden based on user permissions - only HR/CEO/COO see Documents, Next of Kin, and Guarantors tabs

### 3. **Bulk Upload System**
- **CSV Upload**: Upload multiple staff at once via CSV file
- **Field Validation**: Automatically validates required fields
- **Error Reporting**: Shows which rows failed and why
- **Email Automation**: Sends welcome emails to all successfully created staff

---

## 📋 How to Bulk Upload Staff

### Step 1: Prepare Your CSV File

#### Required Columns:
- `full_name` - Full name of staff member
- `email` - Unique email address (will be used for login)
- `phone_number` - Phone number (format: 08012345678)
- `role_id` - UUID of the role from database
- `gender` - Male or Female

#### Optional Columns:
**Personal Information:**
- `date_of_birth` - Format: YYYY-MM-DD
- `marital_status` - Single, Married, Divorced, Widowed
- `state_of_origin` - Nigerian state
- `home_address` - Home address
- `employee_id` - Custom employee ID

**Work Information:**
- `department_id` - UUID of department
- `branch_id` - UUID of branch
- `salary` - Numeric value (e.g., 150000)

**Education:**
- `course_of_study` - Field of study
- `grade` - Grade/class achieved
- `institution` - Name of institution

**Next of Kin:**
- `nok_name` - Next of kin full name
- `nok_relationship` - Relationship (e.g., Spouse, Parent, Sibling)
- `nok_phone` - Phone number
- `nok_email` - Email address
- `nok_home_address` - Home address
- `nok_work_address` - Work address

**Guarantor 1:**
- `g1_name` - Full name
- `g1_phone` - Phone number
- `g1_occupation` - Occupation
- `g1_relationship` - Relationship to staff
- `g1_address` - Home address
- `g1_email` - Email address

**Guarantor 2:**
- `g2_name` - Full name
- `g2_phone` - Phone number
- `g2_occupation` - Occupation
- `g2_relationship` - Relationship to staff
- `g2_address` - Home address
- `g2_email` - Email address

### Step 2: Get Required IDs

Before creating the CSV, you need to get the UUIDs for roles, departments, and branches:

#### Get Role IDs:
```bash
# Query the database
SELECT id, name, category FROM roles ORDER BY category, name;
```

Common role IDs you'll need:
- CEO, COO, HR Manager (senior_admin)
- Branch Manager, Floor Manager (admin)
- Cashier, Cook, Security Guard, etc. (general_staff)

#### Get Department IDs:
```bash
SELECT id, name FROM departments ORDER BY name;
```

Departments:
- Supermarket
- Lounge
- Arcade
- Bakery
- Cinema
- Saloon
- Facility Management
- Compliance

#### Get Branch IDs:
```bash
SELECT id, name FROM branches ORDER BY name;
```

Branches:
- Ace Ogbomosho
- Ace Bodija
- Ace Akobo
- Ace Oyo
- Ace Oluyole
- Ace Abeokuta
- etc.

### Step 3: Create Your CSV

Use the template file: `staff_upload_template_simple.csv`

**Example CSV content:**
```csv
full_name,email,phone_number,role_id,gender,date_of_birth,marital_status,state_of_origin,home_address,employee_id,department_id,branch_id,salary,course_of_study,grade,institution,nok_name,nok_relationship,nok_phone,nok_email,nok_home_address,nok_work_address,g1_name,g1_phone,g1_occupation,g1_relationship,g1_address,g1_email,g2_name,g2_phone,g2_occupation,g2_relationship,g2_address,g2_email
John Doe,john.doe@acesupermarket.com,08012345678,abc-123-role-id,Male,1990-01-15,Single,Lagos,123 Main St,EMP001,dept-id-123,branch-id-456,150000,Computer Science,First Class,UNILAG,Jane Doe,Sister,08098765432,jane@email.com,123 Main St,456 Office St,Mike Smith,08011111111,Engineer,Friend,789 Street,mike@email.com,Sarah Jones,08022222222,Teacher,Colleague,321 Ave,sarah@email.com
Mary Smith,mary.smith@acesupermarket.com,08087654321,abc-123-role-id,Female,1992-05-20,Married,Oyo,456 Second Ave,EMP002,dept-id-123,branch-id-456,140000,Accounting,Second Class Upper,OAU,David Smith,Spouse,08087654322,david@email.com,456 Second Ave,789 Work Place,Grace Ade,08033333333,Teacher,Friend,111 Place,grace@email.com,Peter Ojo,08044444444,Doctor,Colleague,222 Street,peter@email.com
```

**Important Notes:**
1. First row MUST be the header with exact column names
2. All column names must be lowercase with underscores
3. Email must be unique for each staff member
4. Date format must be YYYY-MM-DD
5. Empty optional fields are allowed

### Step 4: Upload the CSV File

#### Option A: Using API Directly (Postman/cURL)

```bash
curl -X POST https://your-backend-url/api/v1/hr/staff/bulk-upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "csv_file=@/path/to/your/staff_data.csv"
```

#### Option B: Using Frontend (Coming Soon)
A dedicated bulk upload page will be added to the Flutter app where HR can:
1. Click "Bulk Upload Staff" button
2. Select CSV file
3. Preview data
4. Upload and see results

### Step 5: Review Upload Results

After upload, you'll receive a response like:
```json
{
  "message": "Bulk upload completed",
  "success_count": 25,
  "error_count": 2,
  "errors": [
    {
      "row": 5,
      "email": "duplicate@email.com",
      "error": "Email already exists"
    },
    {
      "row": 12,
      "email": "invalid@email.com",
      "error": "Missing required fields (full_name, email, phone_number, or role_id)"
    }
  ]
}
```

---

## 🔐 Default Login Credentials

For each staff created via bulk upload:
- **Email**: As specified in CSV
- **Password**: The part before @ in their email

**Example:**
- Email: `john.doe@acesupermarket.com`
- Password: `john.doe`

**⚠️ Staff should change their password on first login!**

---

## ❌ Common Errors and Solutions

### 1. "Email already exists"
**Problem**: Email is already in the database
**Solution**: Use a unique email for each staff member

### 2. "Missing required column: full_name"
**Problem**: CSV header doesn't have required column
**Solution**: Ensure header row has: `full_name,email,phone_number,role_id,gender`

### 3. "Failed to create user: invalid UUID"
**Problem**: role_id, department_id, or branch_id is not a valid UUID
**Solution**: Query the database for correct UUIDs

### 4. "Failed to parse row"
**Problem**: CSV row has formatting issues
**Solution**: Ensure no extra commas, quotes are properly escaped, and all rows have same number of columns

---

## 📄 Bulk Document Upload to Cloudinary

After bulk uploading staff data via CSV, you can upload all their **documents** (passports, certificates, etc.) to Cloudinary in bulk.

### How It Works:
1. Upload staff data via CSV first (creates user records)
2. Prepare document files with specific naming convention
3. Upload all documents at once - they go to Cloudinary
4. Document URLs automatically stored in database

### File Naming Convention:

**Staff Documents:**
```
{staff_id}_{document_type}.{ext}

Examples:
abc-123-uuid_passport.jpg
abc-123-uuid_birth_certificate.pdf
abc-123-uuid_waec_certificate.pdf
def-456-uuid_national_id.jpg
def-456-uuid_nysc_certificate.pdf
```

**Guarantor Documents:**
```
{staff_id}_g{1|2}_{document_type}.{ext}

Examples:
abc-123-uuid_g1_passport.jpg
abc-123-uuid_g1_national_id.pdf
abc-123-uuid_g2_passport.jpg
def-456-uuid_g1_work_id.pdf
```

### Supported Document Types:

**Staff Documents:**
- `passport`
- `national_id`
- `birth_certificate`
- `waec_certificate`
- `neco_certificate`
- `jamb_result`
- `degree_certificate`
- `diploma_certificate`
- `nysc_certificate`
- `state_of_origin_cert`
- `lga_certificate`
- `drivers_license`
- `voters_card`
- `resume`
- `cover_letter`

**Guarantor Documents:**
- `passport`
- `national_id`
- `work_id`

### API Endpoints:

**Upload Staff Documents:**
```bash
curl -X POST https://your-backend/api/v1/hr/documents/bulk-upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "documents=@abc-123_passport.jpg" \
  -F "documents=@abc-123_birth_certificate.pdf" \
  -F "documents=@def-456_national_id.jpg"
```

**Upload Guarantor Documents:**
```bash
curl -X POST https://your-backend/api/v1/hr/documents/guarantor-bulk-upload \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "documents=@abc-123_g1_passport.jpg" \
  -F "documents=@abc-123_g1_national_id.pdf" \
  -F "documents=@abc-123_g2_passport.jpg"
```

### Response Format:

```json
{
  "message": "Bulk document upload completed",
  "success_count": 15,
  "error_count": 2,
  "results": [
    {
      "file": "abc-123_passport.jpg",
      "staff_id": "abc-123-uuid",
      "staff_name": "John Doe",
      "document_type": "passport",
      "url": "https://res.cloudinary.com/your-cloud/image/upload/v123/staff_documents/abc-123/passport.jpg"
    }
  ],
  "errors": [
    {
      "file": "invalid_name.jpg",
      "error": "Invalid filename format. Expected: {staff_id}_{document_type}.{ext}"
    }
  ]
}
```

### Workflow for Bulk Document Upload:

1. **Export staff IDs** from database after CSV upload
2. **Rename all document files** according to naming convention:
   - `{staff_id}_passport.jpg`
   - `{staff_id}_birth_certificate.pdf`
   - etc.
3. **Place all files in one folder**
4. **Upload via API** - all files in single request
5. **Review results** - see which succeeded and which failed
6. **Fix errors and retry** failed uploads

### Organizing Documents Before Upload:

**Recommended Folder Structure:**
```
bulk_documents/
├── staff_docs/
│   ├── abc-123_passport.jpg
│   ├── abc-123_birth_certificate.pdf
│   ├── abc-123_waec_certificate.pdf
│   ├── def-456_passport.jpg
│   └── def-456_national_id.jpg
└── guarantor_docs/
    ├── abc-123_g1_passport.jpg
    ├── abc-123_g1_national_id.pdf
    ├── abc-123_g2_passport.jpg
    └── def-456_g1_work_id.pdf
```

### Benefits:

✅ **Fast Upload**: Upload 100+ documents in seconds  
✅ **Cloudinary Storage**: Professional cloud storage with CDN  
✅ **Automatic URLs**: URLs automatically saved to database  
✅ **Error Recovery**: Failed uploads don't affect successful ones  
✅ **Organized Storage**: Files organized by staff ID in Cloudinary  

### Important Notes:

⚠️ **File Size Limits**: Max 100MB total per request  
⚠️ **Correct Naming**: Files MUST follow naming convention or they'll be rejected  
⚠️ **Staff Must Exist**: Staff ID must exist in database before uploading documents  
⚠️ **Overwrite Protection**: Uploading same document type overwrites previous file  

---

## 📊 Bulk Upload vs Individual Creation

| Feature | Bulk Upload | Individual Creation |
|---------|-------------|---------------------|
| Speed | ⚡ Very Fast (100+ staff in seconds) | 🐌 Slow (2-3 minutes per staff) |
| Documents Upload | ❌ Not supported (upload after creation) | ✅ Supported during creation |
| Profile Pictures | ❌ Not supported (upload after creation) | ✅ Supported during creation |
| Validation | ✅ Batch validation with error report | ✅ Real-time validation |
| Best For | Large batches, new branches | Individual hires, detailed setup |

---

## 🎯 Best Practices

1. **Test with Small Batch First**: Upload 2-3 staff members first to test your CSV format
2. **Keep Backup**: Always keep a copy of your CSV file before uploading
3. **Validate Data**: Check all UUIDs are correct before upload
4. **Upload Documents Separately**: After bulk upload, use individual staff profiles to upload documents
5. **Verify Results**: Check the error report and fix issues before re-uploading failed rows

---

## 🔄 Workflow Recommendation

### For New Branch Setup:
1. **Prepare CSV** with all staff details (without documents)
2. **Bulk Upload** all staff members
3. **Review Errors** and fix any failed uploads
4. **Upload Documents** individually through staff profiles
5. **Verify Logins** - test a few staff accounts
6. **Send Notifications** - inform staff of their credentials

### For Existing Branch:
1. **Create Staff Individually** if only 1-5 people
2. **Use Bulk Upload** if adding 10+ people at once

---

## 📞 Support

If you encounter issues:
1. Check the error message in the upload response
2. Verify your CSV matches the template format
3. Ensure all UUIDs are valid from the database
4. Contact your system administrator if issues persist

---

## 🔒 Security Notes

1. **HR Only**: Only users with senior_admin role can bulk upload
2. **JWT Required**: Must be authenticated with valid token
3. **Email Validation**: Duplicate emails are rejected
4. **Password Security**: Default passwords are hashed with bcrypt
5. **Audit Trail**: All uploads are logged with creator information

---

## Summary

✅ **Staff Termination**: HR can terminate staff with confirmation modal, staff cannot login after termination  
✅ **Role-Based Access**: Only HR/CEO/COO see sensitive data (documents, guarantors)  
✅ **Bulk Upload**: Upload 100+ staff via CSV in seconds instead of hours  
✅ **Error Handling**: Clear error messages for failed uploads  
✅ **Email Automation**: Automatic welcome emails with credentials  

**Template File**: `staff_upload_template_simple.csv`  
**API Endpoint**: `POST /api/v1/hr/staff/bulk-upload`  
**Required Permission**: senior_admin (HR/CEO/COO)
