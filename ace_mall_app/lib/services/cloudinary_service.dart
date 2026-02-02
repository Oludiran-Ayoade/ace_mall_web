import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'desk7uuna';
  static const String uploadPreset = 'flutter_uploads';
  
  late CloudinaryPublic cloudinary;

  CloudinaryService() {
    cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  /// Pick an image from gallery
  Future<File?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Pick an image from camera
  Future<File?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Upload image to Cloudinary
  Future<String> uploadImage(File imageFile, {String folder = 'staff_images'}) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Extract public ID from Cloudinary URL
  /// Note: Image deletion should be done through the backend API for security
  String getPublicIdFromUrl(String url) {
    // Example URL: https://res.cloudinary.com/desk7uuna/image/upload/v1234567890/staff_images/filename.jpg
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    // Find the index of 'upload' and get everything after the version number
    final uploadIndex = pathSegments.indexOf('upload');
    if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
      // Skip 'upload' and version number, join the rest
      final publicIdParts = pathSegments.sublist(uploadIndex + 2);
      final publicId = publicIdParts.join('/');
      // Remove file extension
      return publicId.substring(0, publicId.lastIndexOf('.'));
    }
    
    return '';
  }
}
