import 'package:flutter/material.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FullScreenDocumentPage extends StatefulWidget {
  final String documentUrl;
  final String documentName;

  const FullScreenDocumentPage({
    super.key,
    required this.documentUrl,
    required this.documentName,
  });

  @override
  State<FullScreenDocumentPage> createState() => _FullScreenDocumentPageState();
}

class _FullScreenDocumentPageState extends State<FullScreenDocumentPage> {
  String? localPdfPath;
  bool isLoadingPdf = false;

  @override
  void initState() {
    super.initState();
    // Download PDF if it's a PDF document
    String cleanUrl = widget.documentUrl.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'http://192.168.137.29:8080$cleanUrl';
    }
    if (cleanUrl.toLowerCase().endsWith('.pdf')) {
      _downloadAndSavePdf(cleanUrl);
    }
  }

  Future<void> _downloadAndSavePdf(String url) async {
    setState(() {
      isLoadingPdf = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.documentName}.pdf');
      await file.writeAsBytes(bytes);

      setState(() {
        localPdfPath = file.path;
        isLoadingPdf = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPdf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Clean up the URL
    String cleanUrl = widget.documentUrl.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'http://192.168.137.29:8080$cleanUrl';
    }

    // Check document type
    bool isPDF = cleanUrl.toLowerCase().endsWith('.pdf');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.documentName,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.black),
            onPressed: () async {
              try {
                final Uri url = Uri.parse(cleanUrl);
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            tooltip: 'Open in browser',
          ),
        ],
      ),
      body: isPDF
          ? _buildPDFView(context, cleanUrl)
          : _buildImageView(context, cleanUrl),
    );
  }

  Widget _buildImageView(BuildContext context, String url) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BouncingDotsLoader(
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading document...',
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load document',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      error.toString(),
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final Uri uri = Uri.parse(url);
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        // ignore
                      }
                    },
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Open in Browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPDFView(BuildContext context, String url) {
    if (isLoadingPdf) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BouncingDotsLoader(
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: GoogleFonts.inter(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (localPdfPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load PDF',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final Uri uri = Uri.parse(url);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open PDF: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.open_in_browser),
              label: Text(
                'Open in Browser',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      );
    }

    return PDFView(
      filePath: localPdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      onError: (error) {
      },
      onPageError: (page, error) {
      },
    );
  }
}
