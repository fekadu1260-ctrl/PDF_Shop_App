import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_config.dart';

class UserService {
  Future<UserModel?> getUser(String email) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$email'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    }

    return null;
  }
}
