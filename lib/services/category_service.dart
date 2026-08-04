import 'api_config.dart';"${ApiConfig.baseUrl}/categories"${ApiConfig.baseUrl}/categoriesimport 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryService {

  Future<List<CategoryModel>> fetchCategories() async {

    final response = await http.get(
      Uri.parse("http://localhost:3000/categories"),
    );

    if(response.statusCode == 200){

      final data = jsonDecode(response.body);

      return data.map<CategoryModel>((json){

        return CategoryModel.fromJson(json);

      }).toList();

    }else{

      throw Exception("Failed to load categories");

    }

  }

}
