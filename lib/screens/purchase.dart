import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController referenceController =
      TextEditingController();

  bool loading = false;

  Future<void> _copyAccount(String account) async {
    await Clipboard.setData(ClipboardData(text: account));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account number copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pay(String method) async {
    final reference = referenceController.text.trim();

    if (reference.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your payment transaction/reference number.'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in before making a payment.'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final payment = await paymentService.createPayment(
        userId: user.uid,
        pdfId: widget.pdf.id,
        amount: widget.pdf.price,
        method: method,
        paymentReference: reference,
      );

      if (!mounted) return;

      if (payment != null) {
        final paymentId = payment['id']?.toString() ?? '';

        if (paymentId.isEmpty) {
          throw Exception(
            'Payment ID was not returned by the server.',
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$method payment submitted successfully.',
            ),
          ),
        );

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
        throw Exception('Payment could not be created.');
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

  Widget _accountCard({
    required IconData icon,
    required String title,
    required String account,
    required String name,
    required String buttonText,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              account,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _copyAccount(account),
              icon: const Icon(Icons.copy),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 65,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.pdf.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.pdf.description),
                    const SizedBox(height: 14),
                    Text(
                      '${widget.pdf.price.toStringAsFixed(2)} Birr',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              '💳 How to Pay',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '1. Send the exact PDF price to one of the accounts below.\n'
              '2. Keep your transaction/reference number.\n'
              '3. Enter the reference number below.\n'
              '4. Submit your payment for verification.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            _accountCard(
              icon: Icons.phone_android,
              title: 'Telebirr',
              account: '0955203639',
              name: 'Fikadu / ፍቃዱ',
              buttonText: 'Copy Telebirr Number',
            ),

            _accountCard(
              icon: Icons.account_balance,
              title: 'CBE',
              account: '10005577315911',
              name: 'Fikadu / ፍቃዱ',
              buttonText: 'Copy CBE Account',
            ),

            _accountCard(
              icon: Icons.account_balance_wallet,
              title: 'Abay Bank (Optional)',
              account: '2021011034354014',
              name: 'Fikadu / ፍቃዱ',
              buttonText: 'Copy Abay Account',
            ),

            const SizedBox(height: 10),

            const Text(
              'Transaction / Payment Reference',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: referenceController,
              enabled: !loading,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt_long),
                labelText: 'Transaction reference number',
                hintText: 'Example: TXN123456789',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: loading ? null : () => _pay('Telebirr'),
                icon: const Icon(Icons.phone_android),
                label: const Text(
                  'Submit Telebirr Payment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: loading ? null : () => _pay('CBE'),
                icon: const Icon(Icons.account_balance),
                label: const Text(
                  'Submit CBE Payment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            if (loading) ...[
              const SizedBox(height: 25),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Submitting payment...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your PDF will remain locked until the payment is '
                      'verified by the administrator.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
