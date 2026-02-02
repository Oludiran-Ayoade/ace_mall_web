import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import '../widgets/image_upload_widget.dart';

class TestImageUploadPage extends StatefulWidget {
  const TestImageUploadPage({super.key});

  @override
  State<TestImageUploadPage> createState() => _TestImageUploadPageState();
}

class _TestImageUploadPageState extends State<TestImageUploadPage> {
  String? _uploadedImageUrl;
  bool _isSaving = false;

  Future<void> _handleImageUpload(String imageUrl) async {
    setState(() {
      _uploadedImageUrl = imageUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image uploaded: $imageUrl'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveProfileImage() async {
    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // TODO: Call API to update user profile with image URL
      // await _apiService.updateUserProfile({'profile_image_url': _uploadedImageUrl});
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Image Upload'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Upload Profile Picture',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Test the Cloudinary image upload integration',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Image Upload Widget
            Center(
              child: ImageUploadWidget(
                onImageUploaded: _handleImageUpload,
                initialImageUrl: _uploadedImageUrl,
                folder: 'staff_images',
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Display uploaded URL
            if (_uploadedImageUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uploaded Image URL:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _uploadedImageUrl!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfileImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: BouncingDotsLoader(
                            
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Profile Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
            
            const SizedBox(height: 40),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'How to Use',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Tap the image placeholder to select a photo\n'
                    '2. Choose from Gallery or Camera\n'
                    '3. Wait for upload to complete\n'
                    '4. Image URL will be displayed below\n'
                    '5. Click "Save Profile Image" to save',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
