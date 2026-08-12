import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class CategoryService {
  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categories'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }
}
