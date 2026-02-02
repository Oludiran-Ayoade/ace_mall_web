import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import '../services/file_upload_service.dart';

class FileUploadWidget extends StatefulWidget {
  final Function(String fileUrl, String fileName) onFileUploaded;
  final String? initialFileUrl;
  final String? initialFileName;
  final String folder;
  final String label;
  final List<String> allowedExtensions;

  const FileUploadWidget({
    super.key,
    required this.onFileUploaded,
    this.initialFileUrl,
    this.initialFileName,
    this.folder = 'documents',
    this.label = 'Upload Document',
    this.allowedExtensions = const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final FileUploadService _fileService = FileUploadService();
  String? _uploadedFileUrl;
  String? _uploadedFileName;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _uploadedFileUrl = widget.initialFileUrl;
    _uploadedFileName = widget.initialFileName;
  }

  Future<void> _pickAndUploadFile() async {
    try {
      // Pick file
      final file = await _fileService.pickDocument();
      if (file == null) return;

      setState(() {
        _isUploading = true;
      });

      // Upload to Cloudinary
      final result = await _fileService.uploadDocument(
        file,
        folder: widget.folder,
      );

      final fileName = result['original_filename'] as String;
      final fileUrl = result['url'] as String;

      setState(() {
        _uploadedFileUrl = fileUrl;
        _uploadedFileName = fileName;
        _isUploading = false;
      });

      // Notify parent
      widget.onFileUploaded(fileUrl, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded: $fileName'),
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
            content: Text('Failed to upload file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon() {
    if (_uploadedFileName == null) return Icons.upload_file;
    
    final extension = _uploadedFileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    if (_uploadedFileName == null) return Colors.grey;
    
    final extension = _uploadedFileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isUploading ? null : _pickAndUploadFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _uploadedFileUrl != null
                    ? Colors.green
                    : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: _isUploading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BouncingDotsLoader(size: 8),
                      SizedBox(width: 12),
                      Text('Uploading...'),
                    ],
                  )
                : _uploadedFileUrl != null
                    ? Row(
                        children: [
                          Icon(
                            _getFileIcon(),
                            size: 40,
                            color: _getFileColor(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _uploadedFileName ?? 'Document',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to change',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tap to upload',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                widget.allowedExtensions.join(', ').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
