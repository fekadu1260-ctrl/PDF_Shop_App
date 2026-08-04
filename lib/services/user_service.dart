import 'api_config.dart';"${ApiConfig.baseUrl}/users/$email"import 'api_config.dart';"${ApiConfig.baseUrl}/users/$email"import 'api_config.dart';"${ApiConfig.baseUrl}/users/$email"import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';


class UserService {


  Future<UserModel?> getUser(
      String email) async {


    final response = await http.get(

      Uri.parse(
        "http://localhost:3000/users/$email",
      ),

    );


    if(response.statusCode == 200){

      final data = jsonDecode(
        response.body,
      );


      return UserModel.fromJson(data);

    }


    return null;

  }



  Future<bool> isAdmin(
      String email) async {


    final user = await getUser(email);


    if(user == null){

      return false;

    }


    return user.role == "admin";

  }


}
