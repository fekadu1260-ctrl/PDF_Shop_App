import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class AuthService {
  static const String _tokenKey = 'customer_auth_token';
  static const String _userIdKey = 'customer_user_id';
  static const String _phoneKey = 'customer_phone';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> signInCustomer({
    required String phoneNumber,
    required String accessCode,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/auth/customer-login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'phone': phoneNumber,
            'accessCode': accessCode,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final error =
          data is Map<String, dynamic> ? data['error']?.toString() : null;

      throw Exception(
        error ?? 'Customer login failed (${response.statusCode})',
      );
    }

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid login response from server.');
    }

    final token = data['token']?.toString() ?? '';
    final userId = data['userId']?.toString() ?? '';
    final phone = data['phone']?.toString() ?? phoneNumber;

    if (token.isEmpty || userId.isEmpty) {
      throw Exception('Server did not return a valid customer session.');
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_phoneKey, phone);

    return data;
  }

  Future<String?> getCustomerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getCustomerUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<String?> getCustomerPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  Future<bool> isCustomerLoggedIn() async {
    final token = await getCustomerToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>> customerAuthHeaders() async {
    final token = await getCustomerToken();

    if (token == null || token.isEmpty) {
      throw Exception('Customer is not signed in.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  User? get currentAdminUser => _firebaseAuth.currentUser;

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_phoneKey);

    // This is only relevant when an administrator is signed in.
    await _firebaseAuth.signOut();
  }
}
