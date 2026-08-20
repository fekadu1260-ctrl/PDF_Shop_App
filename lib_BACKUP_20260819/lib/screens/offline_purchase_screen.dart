import 'package:flutter/material.dart';

import '../models/pdf_model.dart';
import '../models/user_model.dart';
import '../services/offline_customer_service.dart';
import '../services/order_service.dart';

class OfflinePurchaseScreen extends StatefulWidget {
  final PdfModel pdf;

  const OfflinePurchaseScreen({
    super.key,
    required this.pdf,
  });

  @override
  State<OfflinePurchaseScreen> createState() => _OfflinePurchaseScreenState();
}

class _OfflinePurchaseScreenState extends State<OfflinePurchaseScreen> {
  final OfflineCustomerService _customerService =
      OfflineCustomerService.instance;

  final OrderService _orderService = OrderService();

  List<UserModel> _customers = [];
  UserModel? _selectedCustomer;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await _customerService.getCustomers();

    if (!mounted) return;

    setState(() {
      _customers = customers;
      _loading = false;
    });
  }

  Future<void> _createOrder() async {
    final customer = _selectedCustomer;

    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer.'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final order = await _orderService.createOrder(
        userId: customer.id,
        pdfId: widget.pdf.id,
        amount: widget.pdf.price,
      );

      if (!mounted) return;

      final isOffline = order.status == 'waiting_sync';

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  isOffline ? Icons.cloud_off : Icons.check_circle,
                ),
                const SizedBox(width: 10),
                Text(
                  isOffline ? 'Sale Saved Offline' : 'Sale Created',
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer: ${customer.name}',
                ),
                const SizedBox(height: 6),
                Text(
                  'Phone: ${customer.phone}',
                ),
                const SizedBox(height: 6),
                Text(
                  'PDF: ${widget.pdf.title}',
                ),
                const SizedBox(height: 6),
                Text(
                  'Amount: ${widget.pdf.price} Birr',
                ),
                const SizedBox(height: 12),
                Text(
                  isOffline
                      ? 'The order is safely stored on this phone and will be synchronized when internet returns.'
                      : 'The order has been sent successfully.',
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context, order);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not create order: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Purchase'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pdf.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: ${widget.pdf.price} Birr',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Select Customer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_customers.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No offline customers yet.\n'
                          'Add a customer first.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _customers.length,
                        itemBuilder: (context, index) {
                          final customer = _customers[index];

                          final selected = _selectedCustomer?.id == customer.id;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  customer.name.isNotEmpty
                                      ? customer.name[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(
                                customer.name.isEmpty
                                    ? 'Unnamed Customer'
                                    : customer.name,
                              ),
                              subtitle: Text(customer.phone),
                              trailing: selected
                                  ? const Icon(
                                      Icons.check_circle,
                                    )
                                  : null,
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  _selectedCustomer = customer;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  if (_customers.isNotEmpty)
                    SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _createOrder,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_cart,
                                ),
                          label: Text(
                            _saving ? 'Saving Sale...' : 'Complete Sale',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
