import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class AdminPdfService {
  Future<bool> uploadPdf({
    required String title,
    required String description,
    required double price,
    required String category,
    required String fileUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Admin is not signed in');
    }

    final idToken = await user.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not obtain Firebase ID token');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pdfs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'fileUrl': fileUrl,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception(
      'PDF upload failed (${response.statusCode}): ${response.body}',
    );
  }
}
