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

  /// Upload image to Cloudinary with automatic optimization
  /// This reduces a 3MB image to typically 300-500KB using f_auto,q_auto
  Future<String> uploadImage(File imageFile, {String folder = 'staff_images'}) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      // Optimize the URL with automatic format and quality
      // This dramatically reduces file size while maintaining visual quality
      return optimizeCloudinaryUrl(response.secureUrl);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Optimizes Cloudinary image URL with automatic format and quality settings
  /// f_auto: Automatically delivers WebP for supported browsers, or JPEG/PNG otherwise
  /// q_auto: Automatically adjusts quality to reduce file size while maintaining visual quality
  /// This typically reduces a 3MB image to 300-500KB
  String optimizeCloudinaryUrl(String url, {int? width, int? height}) {
    if (!url.contains('cloudinary.com') || !url.contains('/upload/')) {
      return url;
    }

    // Split URL into base and path
    final parts = url.split('/upload/');
    if (parts.length != 2) return url;

    // Build transformation string
    final transformations = <String>[
      'f_auto', // Auto format (WebP, JPEG, PNG based on browser support)
      'q_auto', // Auto quality (optimizes compression)
    ];

    // Add optional dimensions
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');

    // Reconstruct optimized URL
    return '${parts[0]}/upload/${transformations.join(',')}/${parts[1]}';
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
