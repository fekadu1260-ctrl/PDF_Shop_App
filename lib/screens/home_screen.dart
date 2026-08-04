import 'package:flutter/material.dart';
import '../models/pdf_model.dart';
import '../services/pdf_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
        title: const Text("PDF Shop"),
      ),

      body: FutureBuilder<List<PdfModel>>(
        future: pdfs,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );

          }


          if (snapshot.hasError) {

            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );

          }


          final pdfList = snapshot.data ?? [];


          return ListView.builder(
            itemCount: pdfList.length,

            itemBuilder: (context, index) {

              final pdf = pdfList[index];


              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(

                  title: Text(pdf.title),

                  subtitle: Text(
                    "${pdf.description}\nPrice: ${pdf.price} birr",
                  ),

                  trailing: ElevatedButton(
                    child: const Text("View"),
                    onPressed: () {},
                  ),

                ),
              );
            },
          );
        },
      ),
    );
  }
}
