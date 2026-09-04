import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class PaymentService {
  final AuthService _authService = AuthService();

  // =========================
  // CUSTOMER: CREATE PAYMENT
  // =========================

  Future<Map<String, dynamic>?> createPayment({
    required String userId,
    required String pdfId,
    required double amount,
    required String method,
    required String paymentReference,
  }) async {
    final headers = await _authService.customerAuthHeaders();

    final url = "${ApiConfig.baseUrl}/payments";

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({
              "userId": userId,
              "pdfId": pdfId,
              "amount": amount,
              "method": method,
              "paymentReference": paymentReference,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }

        throw Exception(
          "Invalid payment response from server",
        );
      }

      throw Exception(
        "Payment creation failed "
        "(${response.statusCode}): ${response.body}",
      );
    } catch (e) {
      throw Exception(
        "Could not connect to payment server.\n"
        "Server: $url\n"
        "Reason: $e",
      );
    }
  }

  // =========================
  // CUSTOMER: CHECK PAYMENT
  // =========================

  Future<String> checkPaymentStatus(
    String paymentId,
  ) async {
    final headers = await _authService.customerAuthHeaders();

    final url = "${ApiConfig.baseUrl}/payments/$paymentId";

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["status"]?.toString() ?? "unknown";
      }

      throw Exception(
        "Failed to check payment status "
        "(${response.statusCode}): ${response.body}",
      );
    } catch (e) {
      throw Exception(
        "Could not check payment status.\n"
        "Server: $url\n"
        "Reason: $e",
      );
    }
  }

  // =========================
  // ADMIN: FETCH PAYMENTS
  // =========================

  Future<List<Map<String, dynamic>>> fetchPayments() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Admin is not signed in");
    }

    final idToken = await user.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        "Could not obtain Firebase ID token",
      );
    }

    final url = "${ApiConfig.baseUrl}/payments";

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $idToken",
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is! List) {
          throw Exception(
            "Invalid payments data received from server",
          );
        }

        return data
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
      }

      throw Exception(
        "Failed to load payments "
        "(${response.statusCode}): ${response.body}",
      );
    } catch (e) {
      throw Exception(
        "Could not load payments.\n"
        "Server: $url\n"
        "Reason: $e",
      );
    }
  }

  // =========================
  // ADMIN: APPROVE PAYMENT
  // =========================

  Future<bool> approvePayment(
    String paymentId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Admin is not signed in");
    }

    final idToken = await user.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        "Could not obtain Firebase ID token",
      );
    }

    final url =
        "${ApiConfig.baseUrl}/payments/$paymentId/approve";

    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $idToken",
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return true;
      }

      throw Exception(
        "Approval failed "
        "(${response.statusCode}): ${response.body}",
      );
    } catch (e) {
      throw Exception(
        "Could not approve payment.\n"
        "Server: $url\n"
        "Reason: $e",
      );
    }
  }
}
