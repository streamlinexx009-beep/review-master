import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('PDF URL: $pdfUrl');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SfPdfViewer.network(
        pdfUrl,

        canShowScrollHead: true,
        canShowScrollStatus: true,

        onDocumentLoaded: (details) {
          debugPrint('PDF LOADED SUCCESSFULLY');
        },

        onDocumentLoadFailed: (details) {
          debugPrint('====================');
          debugPrint('PDF FAILED');
          debugPrint('Error: ${details.error}');
          debugPrint('Description: ${details.description}');
          debugPrint('====================');
        },
      ),
    );
  }
}