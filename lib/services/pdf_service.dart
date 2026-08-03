import 'dart:convert';
import 'package:http/http.dart' as http;

class PdfService {

  Future<List<dynamic>> fetchPdfs() async {

    final response = await http.get(
      Uri.parse("http://localhost:3000/pdfs"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load PDFs");
    }
  }
}
