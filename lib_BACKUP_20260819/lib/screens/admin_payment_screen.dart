import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class AdminPaymentScreen extends StatefulWidget {
  const AdminPaymentScreen({super.key});

  @override
  State<AdminPaymentScreen> createState() => _AdminPaymentScreenState();
}

class _AdminPaymentScreenState extends State<AdminPaymentScreen> {
  final PaymentService paymentService = PaymentService();

  bool loading = true;
  List<Map<String, dynamic>> payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final result = await paymentService.fetchPayments();

      if (!mounted) return;

      setState(() {
        payments = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load payments: $e')),
      );
    }
  }

  Future<void> _approvePayment(String paymentId) async {
    final success = await paymentService.approvePayment(paymentId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Payment approved successfully.' : 'Approval failed.',
        ),
      ),
    );

    if (success) {
      await _loadPayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Verification'),
        actions: [
          IconButton(
            onPressed: loading ? null : _loadPayments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : payments.isEmpty
              ? const Center(
                  child: Text('No payment records found.'),
                )
              : RefreshIndicator(
                  onRefresh: _loadPayments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];

                      final id =
                          payment['id']?.toString() ?? '';

                      final status =
                          payment['status']?.toString() ?? 'pending';

                      final userId =
                          payment['userId']?.toString() ?? '';

                      final pdfId =
                          payment['pdfId']?.toString() ?? '';

                      final method =
                          payment['method']?.toString() ?? '';

                      final reference =
                          payment['paymentReference']?.toString() ?? '';

                      final amount =
                          payment['amount']?.toString() ?? '0';

                      final pending = status == 'pending';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment: $id',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Customer: $userId'),
                              Text('PDF ID: $pdfId'),
                              Text('Amount: $amount Birr'),
                              Text('Method: $method'),
                              Text(
                                'Reference: ${reference.isEmpty ? "Not provided" : reference}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${status.toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: pending
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (pending)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _approvePayment(id),
                                    icon: const Icon(Icons.verified),
                                    label: const Text(
                                      'Approve Payment',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
