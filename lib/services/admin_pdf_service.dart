import 'api_config.dart';Uri.parse("${ApiConfig.baseUrl}/pdfs")import 'api_config.dart';"${ApiConfig.baseUrl}/pdfs"import 'api_config.dart';"${ApiConfig.baseUrl}/pdfs"import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminPdfService {

  Future<bool> uploadPdf({
    required String title,
    required double price,
    required String fileUrl,
  }) async {

    final response = await http.post(

      Uri.parse("http://localhost:3000/pdfs"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "title": title,
        "price": price,
        "fileUrl": fileUrl,

      }),

    );


    return response.statusCode == 200 ||
        response.statusCode == 201;

  }

}
