import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../models/pdf_model.dart';
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
        title: const Text("PDF Library"),
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
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final data = snapshot.data ?? [];

          return ListView.builder(
            itemCount: data.length,

            itemBuilder: (context, index) {

              final pdf = data[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf),

                  title: Text(pdf.title),

                  subtitle: Text(
                    "${pdf.category} - ${pdf.price} Birr",
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PdfDetailsPage(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
builder: (_) => PdfDetailsPage(pdf: pdf),PdfDetailsPage(pdf: pdf)
