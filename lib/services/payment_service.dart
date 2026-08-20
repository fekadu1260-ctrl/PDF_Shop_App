import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class PaymentService {
  Future<Map<String, dynamic>?> createPayment({
    required String userId,
    required String pdfId,
    required double amount,
    required String method,
    required String paymentReference,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/payments"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userId": userId,
        "pdfId": pdfId,
        "amount": amount,
        "method": method,
        "paymentReference": paymentReference,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<String> checkPaymentStatus(String paymentId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User is not signed in");
    }

    final idToken = await user.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception("Could not obtain Firebase ID token");
    }

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/payments/$paymentId"),
      headers: {
        "Authorization": "Bearer $idToken",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"]?.toString() ?? "unknown";
    }

    throw Exception(
      "Failed to check payment status (${response.statusCode}): ${response.body}",
    );
  }

  Future<List<Map<String, dynamic>>> fetchPayments() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/payments"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(
        data.map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
    }

    throw Exception("Failed to load payments");
  }

  Future<bool> approvePayment(String paymentId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Admin is not signed in");
    }

    // Force refresh so the latest admin:true claim is included.
    final idToken = await user.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception("Could not obtain Firebase ID token");
    }

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/payments/$paymentId/approve"),
      headers: {
        "Authorization": "Bearer $idToken",
      },
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(
      "Approval failed (${response.statusCode}): ${response.body}",
    );
  }
}
