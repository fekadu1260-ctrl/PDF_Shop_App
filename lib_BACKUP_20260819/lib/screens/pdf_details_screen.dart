import 'package:flutter/material.dart';

import '../models/pdf_model.dart';
import 'purchase.dart';
import 'offline_purchase_screen.dart';

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
        title: const Text('PDF Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.picture_as_pdf,
                size: 100,
              ),
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
              'Category: ${pdf.category}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '${pdf.price} Birr',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PurchasePage(pdf: pdf),
                    ),
                  );
                },
                child: const Text('Buy PDF'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfflinePurchaseScreen(pdf: pdf),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_off),
                label: const Text('Offline Sale'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
