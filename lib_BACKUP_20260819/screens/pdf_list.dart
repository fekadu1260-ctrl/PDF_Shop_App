import 'package:flutter/material.dart';

import '../models/pdf_model.dart';
import '../services/pdf_service.dart';
import 'pdf_details.dart';

class PdfListPage extends StatefulWidget {
  const PdfListPage({super.key});

  @override
  State<PdfListPage> createState() => _PdfListPageState();
}

class _PdfListPageState extends State<PdfListPage> {
  final PdfService pdfService = PdfService();

  late Future<List<PdfModel>> pdfs;

  @override
  void initState() {
    super.initState();
    pdfs = pdfService.fetchPdfs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Shop'),
      ),
      body: FutureBuilder<List<PdfModel>>(
        future: pdfs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading PDFs: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final pdfList = snapshot.data ?? [];

          if (pdfList.isEmpty) {
            return const Center(
              child: Text('No PDFs available.'),
            );
          }

          return ListView.builder(
            itemCount: pdfList.length,
            itemBuilder: (context, index) {
              final pdf = pdfList[index];

              return ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(pdf.title),
                subtitle: Text('Price: ${pdf.price}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfDetailsPage(pdf: pdf),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
