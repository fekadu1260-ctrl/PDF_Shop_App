import 'package:flutter/material.dart';
import '../models/pdf_model.dart';
import 'purchase.dart';

class PdfDetailsPage extends StatelessWidget {

  final PdfModel pdf;

  const PdfDetailsPage({
    super.key,
    required this.pdf,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Details"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Icon(
              Icons.picture_as_pdf,
              size: 80,
            ),

            const SizedBox(height: 20),

            Text(
              pdf.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(pdf.description),

            const SizedBox(height: 15),

            Text(
              "${pdf.price} Birr",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                child: const Text("Buy PDF"),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PurchasePage(
                        pdf: pdf,
                      ),
                    ),
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
