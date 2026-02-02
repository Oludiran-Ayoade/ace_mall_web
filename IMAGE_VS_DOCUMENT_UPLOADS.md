# Image vs Document Uploads - Implementation Complete ✅

## Overview
Successfully implemented separate handling for **image uploads** (profile pictures) and **document uploads** (certificates, IDs, PDFs) in the Ace Mall Staff Management System.

---

## 🎯 Key Distinction

### 📸 Images (Use `ImageUploadWidget`)
**Purpose:** Photos that will be displayed as images in the UI
- Profile pictures
- Passport photos
- Guarantor photos

**Characteristics:**
- Visual preview before upload
- Displayed inline in the app
- Optimized for web display
- Formats: JPG, PNG only
- Cloudinary resource type: `image`

### 📄 Documents (Use `FileUploadWidget`)
**Purpose:** Official documents that may be downloaded or viewed
- Certificates (WAEC, NECO, JAMB, Degree)
- Identity documents (Birth cert, National ID, Passport)
- Government documents (NYSC, State of Origin)
- Employment documents (Resume, Cover letter)

**Characteristics:**
- File icon preview (PDF, DOC icons)
- Can be PDFs or scanned images
- Stored for download/viewing
- Formats: PDF, DOC, DOCX, JPG, PNG
- Cloudinary resource type: `raw` (for PDFs/docs) or `image` (for scans)

---

## 📂 Files Created

### Frontend (Flutter)

**New Services:**
- ✅ `lib/services/file_upload_service.dart` - Document upload service
- ✅ `lib/services/cloudinary_service.dart` - Image upload service (existing)

**New Widgets:**
- ✅ `lib/widgets/file_upload_widget.dart` - Document upload widget
- ✅ `lib/widgets/image_upload_widget.dart` - Image upload widget (existing)

**New Pages:**
- ✅ `lib/pages/test_upload_types_page.dart` - Demo page showing both types
- ✅ `lib/pages/test_image_upload_page.dart` - Image upload test (existing)

### Backend (Go)

**Updated Handlers:**
- ✅ `backend/handlers/upload.go` - Added `UploadDocument` handler

**Updated Utils:**
- ✅ `backend/utils/cloudinary.go` - Added `UploadDocument` function

**Updated Routes:**
- ✅ `backend/main.go` - Added `/api/v1/upload/document` endpoint

### Documentation
- ✅ `UPLOAD_TYPES_CONFIGURATION.md` - Complete configuration guide
- ✅ `IMAGE_VS_DOCUMENT_UPLOADS.md` - This file

---

## 🔧 API Endpoints

### Image Upload (Profile Pictures)
```http
POST /api/v1/upload/image
Authorization: Bearer <token>
Content-Type: multipart/form-data

Form Data:
- image: File (JPG, PNG)
- folder: string (optional, default: "staff_images")

Response:
{
  "message": "Image uploaded successfully",
  "url": "https://res.cloudinary.com/desk7uuna/image/upload/..."
}
```

### Document Upload (Certificates, IDs, PDFs)
```http
POST /api/v1/upload/document
Authorization: Bearer <token>
Content-Type: multipart/form-data

Form Data:
- file: File (PDF, DOC, DOCX, JPG, PNG)
- folder: string (optional, default: "documents")

Response:
{
  "message": "Document uploaded successfully",
  "url": "https://res.cloudinary.com/desk7uuna/raw/upload/...",
  "public_id": "documents/1234567890_abc123.pdf",
  "original_filename": "waec_certificate.pdf"
}
```

### Delete (Both Images and Documents)
```http
DELETE /api/v1/upload/image
Authorization: Bearer <token>
Content-Type: application/json

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

## 💻 Frontend Usage

### Image Upload Widget
```dart
import 'package:ace_mall_app/widgets/image_upload_widget.dart';

// In your widget
ImageUploadWidget(
  onImageUploaded: (String imageUrl) {
    setState(() {
      profileImageUrl = imageUrl;
    });
  },
  initialImageUrl: existingImageUrl,
  folder: 'staff_images',
)
```

**Features:**
- Camera or gallery selection
- Image preview
- Circular progress indicator
- Change photo option
- Error handling

### File Upload Widget
```dart
import 'package:ace_mall_app/widgets/file_upload_widget.dart';

// In your widget
FileUploadWidget(
  label: 'Upload WAEC Certificate',
  onFileUploaded: (String fileUrl, String fileName) {
    setState(() {
      waecCertUrl = fileUrl;
      waecCertFileName = fileName;
    });
  },
  initialFileUrl: existingFileUrl,
  initialFileName: existingFileName,
  folder: 'certificates/waec',
  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
)
```

**Features:**
- File picker for documents
- File type icons (PDF, DOC, image)
- Color-coded by file type
- Upload progress
- File name display
- Error handling

---

## 📊 Upload Types Configuration

### Images (2 types)
| Field | Widget | Folder | Formats |
|-------|--------|--------|---------|
| Profile Picture | `ImageUploadWidget` | `staff_images` | JPG, PNG |
| Guarantor Photo | `ImageUploadWidget` | `guarantor_photos` | JPG, PNG |

### Documents (25+ types)

#### Educational Certificates
| Document | Folder | Formats |
|----------|--------|---------|
| WAEC Certificate | `certificates/waec` | PDF, JPG, PNG |
| NECO Certificate | `certificates/neco` | PDF, JPG, PNG |
| JAMB Result | `certificates/jamb` | PDF, JPG, PNG |
| Degree Certificate | `certificates/degree` | PDF, JPG, PNG |
| Diploma Certificate | `certificates/diploma` | PDF, JPG, PNG |

#### Identity Documents
| Document | Folder | Formats |
|----------|--------|---------|
| Birth Certificate | `documents/birth_certificates` | PDF, JPG, PNG |
| National ID | `documents/national_ids` | PDF, JPG, PNG |
| Passport | `documents/passports` | PDF, JPG, PNG |
| Driver's License | `documents/licenses` | PDF, JPG, PNG |
| Voter's Card | `documents/voters_cards` | PDF, JPG, PNG |

#### Government Documents
| Document | Folder | Formats |
|----------|--------|---------|
| NYSC Certificate | `documents/nysc` | PDF, JPG, PNG |
| State of Origin Cert | `documents/state_of_origin` | PDF, JPG, PNG |
| LGA Certificate | `documents/lga` | PDF, JPG, PNG |

#### Employment Documents
| Document | Folder | Formats |
|----------|--------|---------|
| Resume/CV | `documents/resumes` | PDF, DOC, DOCX |
| Cover Letter | `documents/cover_letters` | PDF, DOC, DOCX |
| Reference Letters | `documents/references` | PDF, DOC, DOCX |
| Employment Letter | `documents/employment` | PDF, JPG, PNG |

#### Guarantor Documents
| Document | Folder | Formats |
|----------|--------|---------|
| Guarantor ID | `guarantor_documents/ids` | PDF, JPG, PNG |
| Guarantor Work ID | `guarantor_documents/work_ids` | PDF, JPG, PNG |
| Utility Bill | `guarantor_documents/utility_bills` | PDF, JPG, PNG |

---

## 🧪 Testing

### Test Page Route
```dart
Navigator.pushNamed(context, '/test-upload-types');
```

### What the Test Page Demonstrates
1. **Image Upload Section**
   - Profile picture upload with preview
   - Camera/gallery selection
   - Visual image display

2. **Document Upload Section**
   - WAEC certificate upload
   - Birth certificate upload
   - NYSC certificate upload
   - File type icons
   - File name display

3. **Upload Summary**
   - Shows which files have been uploaded
   - Visual checklist

4. **Key Differences Info**
   - Explains when to use each widget
   - Shows format differences

---

## 🎨 Visual Differences

### ImageUploadWidget
```
┌─────────────────┐
│                 │
│   [Image        │
│    Preview]     │
│                 │
│  Add Photo      │
└─────────────────┘
```
- Square/circular container
- Shows actual image
- "Add Photo" text when empty
- Camera icon

### FileUploadWidget
```
┌──────────────────────────────┐
│ 📄  waec_certificate.pdf  ✓  │
│     Tap to change            │
└──────────────────────────────┘
```
- Horizontal layout
- File icon (PDF, DOC, etc.)
- File name displayed
- Color-coded by type
- Checkmark when uploaded

---

## 🔐 Backend Implementation

### Cloudinary Resource Types

**Images:**
```go
uploadParams := uploader.UploadParams{
    PublicID:       uniqueFilename,
    Folder:         folder,
    ResourceType:   "image",
    Transformation: "q_auto,f_auto",
}
```

**Documents:**
```go
uploadParams := uploader.UploadParams{
    PublicID:     uniqueFilename,
    Folder:       folder,
    ResourceType: "raw", // For PDFs, DOCs, etc.
}
```

### File Type Detection
```go
func _getResourceType(extension string) CloudinaryResourceType {
    switch extension {
    case "jpg", "jpeg", "png", "gif":
        return CloudinaryResourceType.Image
    case "pdf", "doc", "docx":
        return CloudinaryResourceType.Raw
    default:
        return CloudinaryResourceType.Raw
    }
}
```

---

## 📁 Cloudinary Folder Structure

```
cloudinary://desk7uuna/
├── staff_images/              # Profile pictures (images)
├── guarantor_photos/          # Guarantor photos (images)
├── certificates/              # Educational certificates (documents)
│   ├── waec/
│   ├── neco/
│   ├── jamb/
│   ├── degree/
│   └── diploma/
├── documents/                 # Official documents
│   ├── birth_certificates/
│   ├── national_ids/
│   ├── passports/
│   ├── nysc/
│   ├── state_of_origin/
│   └── ...
└── guarantor_documents/       # Guarantor documents
    ├── ids/
    ├── work_ids/
    └── utility_bills/
```

---

## ✅ Implementation Checklist

- [x] Created `FileUploadService` for document handling
- [x] Created `FileUploadWidget` with file type icons
- [x] Added backend `UploadDocument` handler
- [x] Added backend `UploadDocument` utility function
- [x] Added `/api/v1/upload/document` endpoint
- [x] Created test page demonstrating both types
- [x] Added route for test page
- [x] Documented all upload types in configuration
- [x] Organized Cloudinary folders by document type
- [x] Implemented file type detection
- [x] Added color-coding for file types
- [x] Backend server restarted with new endpoints

---

## 🎯 Quick Reference

### When to Use ImageUploadWidget
- ✅ Profile pictures
- ✅ Passport-style photos
- ✅ Any photo that will be displayed inline
- ✅ Only JPG/PNG formats needed

### When to Use FileUploadWidget
- ✅ Certificates (can be PDF or scanned)
- ✅ Official documents
- ✅ IDs and government documents
- ✅ Any file that might be PDF
- ✅ Files that need to be downloaded

---

## 🚀 Next Steps

1. **Integrate into Profile Creation:**
   - Add `ImageUploadWidget` for profile picture
   - Add `FileUploadWidget` for each certificate type
   - Update form submission to include URLs

2. **Database Updates:**
   - Store document URLs in appropriate fields
   - Track file names for display
   - Store public_ids for deletion

3. **UI Enhancements:**
   - Add document preview/download buttons
   - Show upload progress for large files
   - Add bulk upload for multiple documents

4. **Validation:**
   - Verify file types before upload
   - Check file sizes
   - Validate required documents

---

## 📞 Support

### Test the Implementation
```bash
# Navigate to test page in running app
Navigator.pushNamed(context, '/test-upload-types');
```

### API Endpoints
- Image Upload: `POST /api/v1/upload/image`
- Document Upload: `POST /api/v1/upload/document`
- Delete: `DELETE /api/v1/upload/image`

### Documentation
- Configuration: `UPLOAD_TYPES_CONFIGURATION.md`
- Setup Guide: `CLOUDINARY_SETUP.md`
- Implementation: `CLOUDINARY_IMPLEMENTATION_COMPLETE.md`

---

**Status:** ✅ Complete and Running
**Backend:** http://localhost:8080
**Test Route:** `/test-upload-types`
**Last Updated:** November 21, 2025
