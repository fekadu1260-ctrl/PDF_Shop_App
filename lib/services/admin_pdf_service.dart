import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AdminPdfService {
  Future<bool> uploadPdf({
    required String title,
    required double price,
    required String fileUrl,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pdfs'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'price': price,
        'fileUrl': fileUrl,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
