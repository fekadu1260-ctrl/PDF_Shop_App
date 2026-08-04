import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pdf_model.dart';
import 'api_config.dart';


class PdfService {

  Future<List<PdfModel>> fetchPdfs() async {

    final response = await http.get(

      Uri.parse(
        "${ApiConfig.baseUrl}/pdfs",
      ),

    );


    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);


      return data
          .map(
            (pdf) => PdfModel.fromJson(pdf),
          )
          .toList();


    } else {

      throw Exception(
        "Failed to load PDFs",
      );

    }

  }

}
