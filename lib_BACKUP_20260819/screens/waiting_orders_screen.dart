import 'package:flutter/material.dart';

import '../services/offline_order_service.dart';
import '../services/order_sync_service.dart';

class WaitingOrdersScreen extends StatefulWidget {
  const WaitingOrdersScreen({super.key});

  @override
  State<WaitingOrdersScreen> createState() => _WaitingOrdersScreenState();
}

class _WaitingOrdersScreenState extends State<WaitingOrdersScreen> {
  final OfflineOrderService _service = OfflineOrderService.instance;

  List<OfflineOrder> _orders = [];
  bool _loading = true;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      await OrderSyncService.instance.syncWaitingOrders();
    } catch (_) {}

    final orders = await _service.getWaitingOrders();

    if (!mounted) return;

    setState(() {
      _orders = orders
          .where(
            (order) => order.syncStatus == 'waiting',
          )
          .toList();

      _loading = false;
    });
  }

  Future<void> _syncNow() async {
    if (_syncing) return;

    setState(() {
      _syncing = true;
    });

    try {
      final count = await OrderSyncService.instance.syncWaitingOrders();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? '$count order(s) synchronized successfully.'
                : 'No orders were synchronized. Internet may be unavailable.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Synchronization failed. Orders remain safely stored offline.',
          ),
        ),
      );
    }

    await _loadOrders();

    if (!mounted) return;

    setState(() {
      _syncing = false;
    });
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '${amount.toInt()} Birr';
    }

    return '${amount.toStringAsFixed(2)} Birr';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    String two(int value) => value.toString().padLeft(2, '0');

    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Waiting Orders (${_orders.length})',
        ),
        actions: [
          IconButton(
            tooltip: 'Sync Now',
            onPressed: _syncing ? null : _syncNow,
            icon: _syncing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.cloud_sync),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _syncing ? null : _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _orders.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_done,
                          size: 70,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No waiting orders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'All orders are synchronized.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.cloud_off,
                              ),
                            ),
                            title: Text(
                              'Order ${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer: ${order.userId}',
                                  ),
                                  Text(
                                    'PDF: ${order.pdfId}',
                                  ),
                                  Text(
                                    'Amount: ${_formatAmount(order.amount)}',
                                  ),
                                  Text(
                                    'Created: ${_formatDate(order.createdAt)}',
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Waiting for internet sync',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
