import 'package:flutter/material.dart';

import '../services/payment_service.dart';

class AdminPaymentScreen extends StatelessWidget {
  AdminPaymentScreen({super.key});

  final PaymentService paymentService = PaymentService();

  Future<void> _approvePayment(BuildContext context) async {
    const paymentId = 'PAYMENT_ID';

    final success = await paymentService.approvePayment(paymentId);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Payment approved' : 'Payment approval failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Verification'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              title: const Text('User: Customer'),
              subtitle: const Text('Status: Pending'),
              trailing: ElevatedButton(
                onPressed: () => _approvePayment(context),
                child: const Text('Approve'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
