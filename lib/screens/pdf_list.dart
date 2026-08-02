import 'package:flutter/material.dart';

class PdfListPage extends StatelessWidget {
  const PdfListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pdfs = [
      "AutoCAD Basics.pdf",
      "Structural Design Notes.pdf",
      "Construction Management.pdf",
      "Civil Engineering Exam Guide.pdf",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Library"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pdfs.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(pdfs[index]),
              subtitle: const Text("Available for purchase"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }

