import 'purchase.dart';import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class PdfDetailsPage extends StatelessWidget {
  const PdfDetailsPage({super.key});

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

            const Text(
              "Structural Design Notes",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Complete civil engineering notes about structural design, "
              "materials and construction concepts.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            const Text(
              "Price: 50 ETB",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Buy PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PurchasePage(),
    ),
  );
},


