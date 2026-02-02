# Upload Types Configuration

## Overview
This document defines which fields should use **image uploads** vs **document/file uploads** in the Ace Mall Staff Management System.

---

## 📸 Image Uploads (Use `ImageUploadWidget`)

### Profile & Personal
- **Profile Picture** - `profile_image_url`
  - Format: JPG, PNG
  - Folder: `staff_images`
  - Max Size: 5MB
  - Widget: `ImageUploadWidget`

### Guarantor Documents
- **Guarantor Passport Photo** - `guarantor_passport_url`
  - Format: JPG, PNG
  - Folder: `guarantor_photos`
  - Max Size: 2MB
  - Widget: `ImageUploadWidget`

---

## 📄 Document/File Uploads (Use `FileUploadWidget`)

### Educational Certificates
- **WAEC Certificate** - `waec_certificate_url`
  - Format: PDF, JPG, PNG
  - Folder: `certificates/waec`
  - Widget: `FileUploadWidget`

- **NECO Certificate** - `neco_certificate_url`
  - Format: PDF, JPG, PNG
  - Folder: `certificates/neco`
  - Widget: `FileUploadWidget`

- **JAMB Result** - `jamb_result_url`
  - Format: PDF, JPG, PNG
  - Folder: `certificates/jamb`
  - Widget: `FileUploadWidget`

- **Degree Certificate** - `degree_certificate_url`
  - Format: PDF, JPG, PNG
  - Folder: `certificates/degree`
  - Widget: `FileUploadWidget`

- **Diploma Certificate** - `diploma_certificate_url`
  - Format: PDF, JPG, PNG
  - Folder: `certificates/diploma`
  - Widget: `FileUploadWidget`

### Identity Documents
- **Birth Certificate** - `birth_certificate_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/birth_certificates`
  - Widget: `FileUploadWidget`

- **National ID Card** - `national_id_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/national_ids`
  - Widget: `FileUploadWidget`

- **International Passport** - `passport_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/passports`
  - Widget: `FileUploadWidget`

- **Driver's License** - `drivers_license_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/licenses`
  - Widget: `FileUploadWidget`

- **Voter's Card** - `voters_card_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/voters_cards`
  - Widget: `FileUploadWidget`

### Government Documents
- **NYSC Certificate** - `nysc_certificate_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/nysc`
  - Widget: `FileUploadWidget`

- **NYSC Discharge Certificate** - `nysc_discharge_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/nysc`
  - Widget: `FileUploadWidget`

- **State of Origin Certificate** - `state_of_origin_cert_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/state_of_origin`
  - Widget: `FileUploadWidget`

- **Local Government Certificate** - `lga_certificate_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/lga`
  - Widget: `FileUploadWidget`

### Medical Documents
- **Medical Certificate** - `medical_certificate_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/medical`
  - Widget: `FileUploadWidget`

- **Health Insurance Card** - `health_insurance_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/insurance`
  - Widget: `FileUploadWidget`

### Employment Documents
- **Resume/CV** - `resume_url`
  - Format: PDF, DOC, DOCX
  - Folder: `documents/resumes`
  - Widget: `FileUploadWidget`

- **Cover Letter** - `cover_letter_url`
  - Format: PDF, DOC, DOCX
  - Folder: `documents/cover_letters`
  - Widget: `FileUploadWidget`

- **Reference Letters** - `reference_letters_url`
  - Format: PDF, DOC, DOCX
  - Folder: `documents/references`
  - Widget: `FileUploadWidget`

- **Previous Employment Letter** - `employment_letter_url`
  - Format: PDF, JPG, PNG
  - Folder: `documents/employment`
  - Widget: `FileUploadWidget`

### Guarantor Documents
- **Guarantor National ID** - `guarantor_id_url`
  - Format: PDF, JPG, PNG
  - Folder: `guarantor_documents/ids`
  - Widget: `FileUploadWidget`

- **Guarantor Work ID** - `guarantor_work_id_url`
  - Format: PDF, JPG, PNG
  - Folder: `guarantor_documents/work_ids`
  - Widget: `FileUploadWidget`

- **Guarantor Utility Bill** - `guarantor_utility_bill_url`
  - Format: PDF, JPG, PNG
  - Folder: `guarantor_documents/utility_bills`
  - Widget: `FileUploadWidget`

---

## 🔧 Implementation Guide

### For Images (Profile Pictures)
```dart
ImageUploadWidget(
  onImageUploaded: (url) {
    setState(() => profileImageUrl = url);
  },
  folder: 'staff_images',
)
```

### For Documents (Certificates, IDs, etc.)
```dart
FileUploadWidget(
  label: 'Upload WAEC Certificate',
  onFileUploaded: (url, fileName) {
    setState(() {
      waecCertificateUrl = url;
      waecFileName = fileName;
    });
  },
  folder: 'certificates/waec',
  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
)
```

---

## 📊 Summary

### Image Uploads (2 types)
- Profile Picture
- Guarantor Passport Photo

### Document Uploads (25+ types)
- Educational Certificates (5)
- Identity Documents (5)
- Government Documents (4)
- Medical Documents (2)
- Employment Documents (4)
- Guarantor Documents (3)

---

## 🎯 Backend API Endpoints

### Image Upload
```
POST /api/v1/upload/image
Content-Type: multipart/form-data
Authorization: Bearer <token>

Form Data:
- image: File
- folder: string (optional, default: "staff_images")

Response:
{
  "message": "Image uploaded successfully",
  "url": "https://res.cloudinary.com/..."
}
```

### Document Upload
```
POST /api/v1/upload/document
Content-Type: multipart/form-data
Authorization: Bearer <token>

Form Data:
- file: File
- folder: string (optional, default: "documents")

Response:
{
  "message": "Document uploaded successfully",
  "url": "https://res.cloudinary.com/...",
  "public_id": "documents/1234567890_abc123.pdf",
  "original_filename": "waec_certificate.pdf"
}
```

### Delete File (Images or Documents)
```
DELETE /api/v1/upload/image
Content-Type: application/json
Authorization: Bearer <token>

Body:
{
  "public_id": "documents/1234567890_abc123.pdf"
}

Response:
{
  "message": "Image deleted successfully"
}
```

---

## 📁 Cloudinary Folder Structure

```
cloudinary://
├── staff_images/           # Profile pictures
├── guarantor_photos/       # Guarantor passport photos
├── certificates/
│   ├── waec/
│   ├── neco/
│   ├── jamb/
│   ├── degree/
│   └── diploma/
├── documents/
│   ├── birth_certificates/
│   ├── national_ids/
│   ├── passports/
│   ├── licenses/
│   ├── voters_cards/
│   ├── nysc/
│   ├── state_of_origin/
│   ├── lga/
│   ├── medical/
│   ├── insurance/
│   ├── resumes/
│   ├── cover_letters/
│   ├── references/
│   └── employment/
└── guarantor_documents/
    ├── ids/
    ├── work_ids/
    └── utility_bills/
```

---

## ✅ Best Practices

1. **Use ImageUploadWidget for:**
   - Photos that need to be displayed as images
   - Profile pictures
   - Passport-style photos

2. **Use FileUploadWidget for:**
   - Certificates (can be PDF or scanned images)
   - Official documents
   - Any file that might be in PDF format

3. **Allowed Extensions:**
   - Images: `['jpg', 'jpeg', 'png']`
   - Documents: `['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx']`

4. **Folder Organization:**
   - Use descriptive folder names
   - Group related documents together
   - Maintain consistent naming convention

5. **File Size Limits:**
   - Profile images: 5MB max
   - Documents: 10MB max
   - Adjust in Cloudinary settings if needed

---

**Last Updated:** November 21, 2025
