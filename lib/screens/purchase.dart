import 'package:flutter/material.dart';

import '../models/pdf_model.dart';

class PurchasePage extends StatelessWidget {
  final PdfModel pdf;

  const PurchasePage({
    super.key,
    required this.pdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase PDF'),
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
              'Price: ${pdf.price} Birr',
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Choose payment method:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Telebirr payment coming soon.'),
                    ),
                  );
                },
                child: const Text('Pay with Telebirr'),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CBE payment coming soon.'),
                    ),
                  );
                },
                child: const Text('Pay with CBE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
