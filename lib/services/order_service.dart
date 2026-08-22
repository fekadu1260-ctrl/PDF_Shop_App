import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import 'api_config.dart';
import 'offline_order_service.dart';

class OrderService {
  final OfflineOrderService _offlineService =
      OfflineOrderService.instance;

  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final token = await user.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('Could not obtain Firebase authentication token.');
    }

    return token;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getAuthToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<OrderModel> createOrder({
    required String userId,
    required String pdfId,
    required double amount,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/orders"),
        headers: headers,
        body: jsonEncode({
          "pdfId": pdfId,
          "amount": amount,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return OrderModel.fromJson(
          jsonDecode(response.body),
        );
      }

      throw Exception(
        "Server returned ${response.statusCode}: ${response.body}",
      );
    } catch (_) {
      final offlineOrder =
          await _offlineService.createOfflineOrder(
        userId: userId,
        pdfId: pdfId,
        amount: amount,
      );

      return OrderModel(
        id: offlineOrder.id,
        userId: offlineOrder.userId,
        pdfId: offlineOrder.pdfId,
        amount: offlineOrder.amount,
        status: 'waiting_sync',
        createdAt: offlineOrder.createdAt,
      );
    }
  }

  Future<List<dynamic>> fetchOrders() async {
    try {
      final headers = await _authHeaders();

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/orders"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception(
        "Failed to load orders: ${response.statusCode}",
      );
    } catch (_) {
      final offlineOrders =
          await _offlineService.getWaitingOrders();

      return offlineOrders
          .map((order) => order.toJson())
          .toList();
    }
  }

  Future<bool> hasPurchased(
    String userId,
    String pdfId,
  ) async {
    try {
      final orders = await fetchOrders();

      for (final order in orders) {
        if (order["userId"] == userId &&
            order["pdfId"] == pdfId &&
            order["status"] == "paid") {
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  Future<List<OfflineOrder>> getWaitingOrders() async {
    return _offlineService.getWaitingOrders();
  }
}
