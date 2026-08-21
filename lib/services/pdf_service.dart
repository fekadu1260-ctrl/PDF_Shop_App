import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pdf_model.dart';
import 'api_config.dart';

class PdfService {
  Future<List<PdfModel>> fetchPdfs() async {
    final url = "${ApiConfig.baseUrl}/pdfs";

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid PDF data received from server');
      }

      return decoded
          .map(
            (pdf) => PdfModel.fromJson(
              Map<String, dynamic>.from(pdf),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Could not connect to PDF server.\n'
        'Server: $url\n'
        'Reason: $e',
      );
    }
  }
}
