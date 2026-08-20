import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../services/payment_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String paymentId;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.paymentId,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PaymentService paymentService = PaymentService();

  bool loading = true;
  bool approved = false;
  String status = 'pending';

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final result = await paymentService.checkPaymentStatus(
        widget.paymentId,
      );

      if (!mounted) return;

      setState(() {
        status = result;
        approved = result == 'approved' || result == 'paid';
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        status = 'error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('PDF Viewer')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!approved) {
      return Scaffold(
        appBar: AppBar(title: const Text('PDF Access')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_top,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Verification Pending',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current status: ${status.toUpperCase()}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => loading = true);
                    _checkAccess();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
      ),
    );
  }
}
