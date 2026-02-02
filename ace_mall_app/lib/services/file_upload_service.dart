import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class FileUploadService {
  static const String cloudName = 'desk7uuna';
  static const String uploadPreset = 'flutter_uploads';
  
  late CloudinaryPublic cloudinary;

  FileUploadService() {
    cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  /// Pick a document file (PDF, DOC, DOCX, etc.)
  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Pick multiple documents
  Future<List<File>?> pickMultipleDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick files: $e');
    }
  }

  /// Upload document/file to Cloudinary
  Future<Map<String, dynamic>> uploadDocument(
    File file, {
    String folder = 'documents',
    String? fileName,
  }) async {
    try {
      // Determine resource type based on file extension
      final extension = file.path.split('.').last.toLowerCase();
      final resourceType = _getResourceType(extension);

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: resourceType,
          publicId: fileName,
        ),
      );

      return {
        'url': response.secureUrl,
        'public_id': response.publicId,
        'original_filename': file.path.split('/').last,
      };
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload multiple documents
  Future<List<Map<String, dynamic>>> uploadMultipleDocuments(
    List<File> files, {
    String folder = 'documents',
  }) async {
    List<Map<String, dynamic>> results = [];
    
    for (File file in files) {
      try {
        final result = await uploadDocument(file, folder: folder);
        results.add(result);
      } catch (e) {
        // Continue with other files even if one fails
        results.add({
          'error': e.toString(),
          'file': file.path,
        });
      }
    }
    
    return results;
  }

  /// Get resource type based on file extension
  CloudinaryResourceType _getResourceType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return CloudinaryResourceType.Image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return CloudinaryResourceType.Video;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      default:
        return CloudinaryResourceType.Raw; // For documents
    }
  }

  /// Get file size in readable format
  String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get file icon based on extension
  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      default:
        return '📎';
    }
  }

  /// Extract public ID from Cloudinary URL
  String getPublicIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    final uploadIndex = pathSegments.indexOf('upload');
    if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
      final publicIdParts = pathSegments.sublist(uploadIndex + 2);
      final publicId = publicIdParts.join('/');
      // Remove file extension
      final lastDot = publicId.lastIndexOf('.');
      return lastDot != -1 ? publicId.substring(0, lastDot) : publicId;
    }
    
    return '';
  }
}
