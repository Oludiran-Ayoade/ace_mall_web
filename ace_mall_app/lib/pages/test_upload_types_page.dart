import 'package:flutter/material.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/file_upload_widget.dart';

class TestUploadTypesPage extends StatefulWidget {
  const TestUploadTypesPage({super.key});

  @override
  State<TestUploadTypesPage> createState() => _TestUploadTypesPageState();
}

class _TestUploadTypesPageState extends State<TestUploadTypesPage> {
  // Image uploads
  String? _profileImageUrl;
  
  // Document uploads
  String? _waecCertUrl;
  String? _waecCertFileName;
  String? _birthCertUrl;
  String? _birthCertFileName;
  String? _nyscCertUrl;
  String? _nyscCertFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Types Demo'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Upload Types Configuration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Demonstrates the difference between image and document uploads',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // IMAGE UPLOADS SECTION
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
                      Icon(Icons.image, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'IMAGE UPLOADS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For photos that will be displayed as images (profile pictures, passport photos)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Picture Upload
            Center(
              child: ImageUploadWidget(
                onImageUploaded: (url) {
                  setState(() => _profileImageUrl = url);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile image uploaded'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                initialImageUrl: _profileImageUrl,
                folder: 'staff_images',
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Profile Picture',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // DOCUMENT UPLOADS SECTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'DOCUMENT UPLOADS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For certificates, IDs, and official documents (PDFs, scanned images)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // WAEC Certificate
            FileUploadWidget(
              label: 'WAEC Certificate',
              onFileUploaded: (url, fileName) {
                setState(() {
                  _waecCertUrl = url;
                  _waecCertFileName = fileName;
                });
              },
              initialFileUrl: _waecCertUrl,
              initialFileName: _waecCertFileName,
              folder: 'certificates/waec',
              allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
            ),
            const SizedBox(height: 16),

            // Birth Certificate
            FileUploadWidget(
              label: 'Birth Certificate',
              onFileUploaded: (url, fileName) {
                setState(() {
                  _birthCertUrl = url;
                  _birthCertFileName = fileName;
                });
              },
              initialFileUrl: _birthCertUrl,
              initialFileName: _birthCertFileName,
              folder: 'documents/birth_certificates',
              allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
            ),
            const SizedBox(height: 16),

            // NYSC Certificate
            FileUploadWidget(
              label: 'NYSC Certificate',
              onFileUploaded: (url, fileName) {
                setState(() {
                  _nyscCertUrl = url;
                  _nyscCertFileName = fileName;
                });
              },
              initialFileUrl: _nyscCertUrl,
              initialFileName: _nyscCertFileName,
              folder: 'documents/nysc',
              allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
            ),

            const SizedBox(height: 40),

            // Summary Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Profile Image', _profileImageUrl != null),
                  _buildSummaryRow('WAEC Certificate', _waecCertUrl != null),
                  _buildSummaryRow('Birth Certificate', _birthCertUrl != null),
                  _buildSummaryRow('NYSC Certificate', _nyscCertUrl != null),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Box
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
                        'Key Differences',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('📸', 'ImageUploadWidget', 'For photos (JPG, PNG only)'),
                  const SizedBox(height: 8),
                  _buildInfoRow('📄', 'FileUploadWidget', 'For documents (PDF, DOC, images)'),
                  const SizedBox(height: 8),
                  _buildInfoRow('🎯', 'Use Case', 'Images = display, Documents = download'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, bool uploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            uploaded ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: uploaded ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
