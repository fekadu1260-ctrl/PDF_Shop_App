import 'package:flutter/material.dart';
import '../models/pdf_model.dart';
import '../services/payment_service.dart';
import 'payment_waiting_screen.dart';

class PurchasePage extends StatefulWidget {
  final PdfModel pdf;

  const PurchasePage({
    super.key,
    required this.pdf,
  });

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final PaymentService paymentService = PaymentService();
  final TextEditingController referenceController = TextEditingController();

  bool loading = false;

  Future<void> _pay(String method) async {
    final reference = referenceController.text.trim();

    if (reference.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your payment reference number.'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final payment = await paymentService.createPayment(
        userId: 'demo-user',
        pdfId: widget.pdf.id,
        amount: widget.pdf.price.toDouble(),
        method: method,
        paymentReference: reference,
      );

      if (!mounted) return;

      if (payment != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$method payment submitted successfully. Order is pending verification.',
            ),
          ),
        );

        final paymentId = payment['id']?.toString() ?? '';

        if (paymentId.isEmpty) {
          throw Exception('Payment ID was not returned by server');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWaitingScreen(
              pdf: widget.pdf,
              paymentId: paymentId,
            ),
          ),
        );
      } else {
        throw Exception('Payment could not be created');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase PDF'),
      ),
      body: SingleChildScrollView(
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
              widget.pdf.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),
            Text(widget.pdf.description),

            const SizedBox(height: 15),

            Text(
              'Price: ${widget.pdf.price} Birr',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Payment reference number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: referenceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Telebirr/CBE transaction number',
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : () => _pay('Telebirr'),
                icon: const Icon(Icons.phone_android),
                label: const Text('Pay with Telebirr'),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : () => _pay('CBE'),
                icon: const Icon(Icons.account_balance),
                label: const Text('Pay with CBE'),
              ),
            ),

            if (loading) ...[
              const SizedBox(height: 25),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
