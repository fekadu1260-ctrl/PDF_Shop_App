import 'package:flutter/material.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
      ),
      body: Center(
        child: Text(
          "PDF URL:\n$pdfUrl",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
