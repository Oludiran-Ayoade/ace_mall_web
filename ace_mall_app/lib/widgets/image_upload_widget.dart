import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final Function(String imageUrl) onImageUploaded;
  final String? initialImageUrl;
  final String folder;

  const ImageUploadWidget({
    super.key,
    required this.onImageUploaded,
    this.initialImageUrl,
    this.folder = 'staff_images',
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.initialImageUrl;
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      // Pick image
      File? imageFile;
      if (source == ImageSource.gallery) {
        imageFile = await _cloudinaryService.pickImageFromGallery();
      } else {
        imageFile = await _cloudinaryService.pickImageFromCamera();
      }

      if (imageFile == null) return;

      setState(() {
        _selectedImage = imageFile;
        _isUploading = true;
      });

      // Upload to Cloudinary
      final imageUrl = await _cloudinaryService.uploadImage(
        imageFile,
        folder: widget.folder,
      );

      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
      });

      // Notify parent
      widget.onImageUploaded(imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourceDialog,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: _isUploading
                ? const Center(child: BouncingDotsLoader())
                : _uploadedImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _uploadedImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 50);
                          },
                        ),
                      )
                    : _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 50, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
          ),
        ),
        if (_uploadedImageUrl != null && !_isUploading)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.edit),
              label: const Text('Change Photo'),
            ),
          ),
      ],
    );
  }
}
