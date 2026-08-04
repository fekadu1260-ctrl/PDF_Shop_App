import 'package:flutter/material.dart';
import '../models/pdf_model.dart';

class PdfDetailsScreen extends StatelessWidget {
  final PdfModel pdf;

  const PdfDetailsScreen({
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

            Text(
const SizedBox(height: 30),

ElevatedButton(
  child: const Text("Buy Now 💳"),
  onPressed: () {

    // Order creation will be connected next

  },
),              pdf.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              pdf.description,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Price: ${pdf.price} birr",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(

              onPressed: () {
                // Purchase flow will be added here
              },

              child: const Text(
                "Purchase Now",
              ),
            ),

          ],
        ),
      ),
    );
  }
}
