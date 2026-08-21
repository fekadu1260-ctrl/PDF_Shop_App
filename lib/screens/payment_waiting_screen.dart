import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pdf_model.dart';
import '../services/payment_service.dart';
import 'pdf_viewer_screen.dart';

class PaymentWaitingScreen extends StatefulWidget {
  final PdfModel pdf;
  final String paymentId;

  const PaymentWaitingScreen({
    super.key,
    required this.pdf,
    required this.paymentId,
  });

  @override
  State<PaymentWaitingScreen> createState() =>
      _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState
    extends State<PaymentWaitingScreen> {
  final PaymentService paymentService = PaymentService();

  String status = 'pending';
  String? errorMessage;
  bool checking = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkStatus(),
    );

    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (checking) return;

    checking = true;

    if (mounted) {
      setState(() {
        errorMessage = null;
      });
    }

    try {
      final result = await paymentService.checkPaymentStatus(
        widget.paymentId,
      );

      if (!mounted) return;

      setState(() {
        status = result;
        errorMessage = null;
      });

      if (result == 'approved' || result == 'paid') {
        timer?.cancel();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      checking = false;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approved =
        status == 'approved' || status == 'paid';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                approved
                    ? Icons.verified
                    : Icons.hourglass_top,
                size: 90,
              ),

              const SizedBox(height: 20),

              Text(
                approved
                    ? 'Payment Verified!'
                    : 'Payment Submitted',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                approved
                    ? 'Your payment has been verified. You can now open the PDF.'
                    : 'Your payment is waiting for verification.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Text(
                'Status: ${status.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Text(
                    'Connection problem:\n$errorMessage',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              if (approved)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(
                            pdfUrl: widget.pdf.fileUrl,
                            paymentId: widget.paymentId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.picture_as_pdf,
                    ),
                    label: const Text('OPEN PDF'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        checking ? null : _checkStatus,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      checking
                          ? 'CHECKING...'
                          : 'CHECK VERIFICATION',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
