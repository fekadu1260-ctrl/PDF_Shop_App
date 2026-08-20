import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'offline_order_service.dart';

class OrderSyncService {
  static final OrderSyncService instance = OrderSyncService._internal();

  OrderSyncService._internal();

  final OfflineOrderService _offlineService = OfflineOrderService.instance;

  Future<int> syncWaitingOrders() async {
    final orders = await _offlineService.getWaitingOrders();

    int syncedCount = 0;

    for (final order in orders) {
      if (order.syncStatus != 'waiting') {
        continue;
      }

      try {
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/orders"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "userId": order.userId,
            "pdfId": order.pdfId,
            "amount": order.amount,
            "status": order.status,
            "createdAt": order.createdAt.toIso8601String(),
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await _offlineService.markAsSynced(order.id);
          syncedCount++;
        }
      } catch (_) {
        // Internet is still unavailable.
        // Leave the order waiting for the next attempt.
      }
    }

    return syncedCount;
  }
}
