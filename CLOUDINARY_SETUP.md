# Cloudinary Integration Setup

## Overview
This project uses Cloudinary for image storage and management. Images are uploaded directly from the Flutter app to Cloudinary using unsigned uploads.

## Configuration

### Cloudinary Account Details
- **Cloud Name**: `desk7uuna`
- **API Key**: `298988719545274`
- **Upload Preset**: `flutter_uploads` (unsigned)

### Backend Configuration
The backend is configured with Cloudinary credentials in `.env`:

```env
CLOUDINARY_CLOUD_NAME=desk7uuna
CLOUDINARY_API_KEY=298988719545274
CLOUDINARY_API_SECRET=H79r0vR_K72aZm_vGHQ1KF1_XXA
CLOUDINARY_UPLOAD_PRESET=flutter_uploads
```

## API Endpoints

### Get Cloudinary Config
```
GET /api/v1/cloudinary/config
```
Returns the cloud name and upload preset for frontend use.

**Response:**
```json
{
  "cloud_name": "desk7uuna",
  "upload_preset": "flutter_uploads"
}
```

### Upload Image (Backend)
```
POST /api/v1/upload/image
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Parameters:**
- `image` (file): The image file to upload
- `folder` (string, optional): Folder name in Cloudinary (default: "staff_images")

**Response:**
```json
{
  "message": "Image uploaded successfully",
  "url": "https://res.cloudinary.com/desk7uuna/image/upload/v1234567890/staff_images/filename.jpg"
}
```

## Flutter Usage

### 1. Import the Service
```dart
import 'package:ace_mall_app/services/cloudinary_service.dart';
```

### 2. Initialize the Service
```dart
final CloudinaryService cloudinaryService = CloudinaryService();
```

### 3. Pick and Upload Image

#### From Gallery
```dart
File? imageFile = await cloudinaryService.pickImageFromGallery();
if (imageFile != null) {
  String imageUrl = await cloudinaryService.uploadImage(
    imageFile,
    folder: 'staff_images',
  );
  print('Uploaded image URL: $imageUrl');
}
```

#### From Camera
```dart
File? imageFile = await cloudinaryService.pickImageFromCamera();
if (imageFile != null) {
  String imageUrl = await cloudinaryService.uploadImage(
    imageFile,
    folder: 'staff_images',
  );
  print('Uploaded image URL: $imageUrl');
}
```

### 4. Using the ImageUploadWidget

The project includes a pre-built widget for easy image uploads:

```dart
import 'package:ace_mall_app/widgets/image_upload_widget.dart';

// In your widget
ImageUploadWidget(
  onImageUploaded: (String imageUrl) {
    // Handle the uploaded image URL
    print('Image uploaded: $imageUrl');
    // Save to database, update state, etc.
  },
  initialImageUrl: 'https://...', // Optional: existing image URL
  folder: 'staff_images', // Optional: custom folder
)
```

## Features

### CloudinaryService Methods

- **`pickImageFromGallery()`**: Opens gallery to select an image
- **`pickImageFromCamera()`**: Opens camera to take a photo
- **`uploadImage(File imageFile, {String folder})`**: Uploads image to Cloudinary
- **`getPublicIdFromUrl(String url)`**: Extracts public ID from Cloudinary URL

### Image Upload Widget Features

- ✅ Pick from gallery or camera
- ✅ Image preview before upload
- ✅ Loading indicator during upload
- ✅ Error handling with user feedback
- ✅ Support for initial/existing images
- ✅ Customizable folder organization

## Image Organization

Images are organized in folders:
- `staff_images/` - Staff profile photos and related images
- `documents/` - Document scans and uploads
- `products/` - Product images (if needed)

## Security Notes

1. **Unsigned Uploads**: The Flutter app uses unsigned uploads with the `flutter_uploads` preset
2. **Backend Uploads**: For sensitive operations, use the backend API endpoint which requires authentication
3. **Image Deletion**: Should only be done through the backend API for security

## Cloudinary Dashboard

Access your Cloudinary dashboard at:
https://console.cloudinary.com/

### Upload Preset Settings
- **Name**: `flutter_uploads`
- **Signing Mode**: Unsigned
- **Folder**: Can be specified per upload
- **Unique filename**: Enabled
- **Overwrite**: Disabled

## Troubleshooting

### Upload Fails
1. Check internet connection
2. Verify upload preset name is correct
3. Check image file size (max 10MB recommended)
4. Ensure image format is supported (JPG, PNG, GIF, etc.)

### Image Not Displaying
1. Verify the URL is accessible
2. Check network permissions in iOS/Android
3. Ensure HTTPS is used for image URLs

## iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload images</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos</string>
```

## Android Permissions

Already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

## Best Practices

1. **Image Optimization**: Images are automatically optimized by Cloudinary
2. **Responsive Images**: Use Cloudinary transformations for different screen sizes
3. **Caching**: Cloudinary provides CDN caching automatically
4. **Naming**: Use descriptive folder names for better organization
5. **Cleanup**: Implement image deletion through backend when users remove images

## Example: Complete Upload Flow

```dart
import 'package:flutter/material.dart';
import 'package:ace_mall_app/services/cloudinary_service.dart';

class ProfileImageUpload extends StatefulWidget {
  @override
  _ProfileImageUploadState createState() => _ProfileImageUploadState();
}

class _ProfileImageUploadState extends State<ProfileImageUpload> {
  final CloudinaryService _cloudinary = CloudinaryService();
  String? _profileImageUrl;
  bool _isUploading = false;

  Future<void> _uploadProfileImage() async {
    setState(() => _isUploading = true);
    
    try {
      // Pick image
      final imageFile = await _cloudinary.pickImageFromGallery();
      if (imageFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Upload to Cloudinary
      final imageUrl = await _cloudinary.uploadImage(
        imageFile,
        folder: 'staff_images',
      );

      setState(() {
        _profileImageUrl = imageUrl;
        _isUploading = false;
      });

      // TODO: Save imageUrl to your database via API
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image updated!')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _profileImageUrl != null
              ? NetworkImage(_profileImageUrl!)
              : null,
          child: _profileImageUrl == null
              ? Icon(Icons.person, size: 60)
              : null,
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _uploadProfileImage,
          icon: _isUploading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.upload),
          label: Text(_isUploading ? 'Uploading...' : 'Upload Photo'),
        ),
      ],
    );
  }
}
```

## Support

For Cloudinary-specific issues, refer to:
- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Flutter Plugin Documentation](https://pub.dev/packages/cloudinary_public)
