import 'package:flutter/material.dart';
import '../pages/full_screen_document_page.dart';

class DocumentViewer extends StatelessWidget {
  final String documentUrl;
  final String documentName;

  const DocumentViewer({
    super.key,
    required this.documentUrl,
    required this.documentName,
  });

  void _openFullScreenDocument(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenDocumentPage(
          documentUrl: documentUrl,
          documentName: documentName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openFullScreenDocument(context),
      icon: const Icon(Icons.visibility),
      color: const Color(0xFF4CAF50),
      tooltip: 'View document',
    );
  }
}
