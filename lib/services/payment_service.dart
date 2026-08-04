import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';


class PaymentService {


  Future<bool> createPayment({

    required String userId,
    required String pdfId,
    required double amount,

  }) async {


    final response = await http.post(

      Uri.parse(
        "${ApiConfig.baseUrl}/payments",
      ),

      headers: {

        "Content-Type": "application/json",

      },


      body: jsonEncode({

        "userId": userId,
        "pdfId": pdfId,
        "amount": amount,

      }),

    );


    return response.statusCode == 200 ||
           response.statusCode == 201;

  }



  Future<String> checkPaymentStatus(
      String paymentId) async {


    final response = await http.get(

      Uri.parse(
        "${ApiConfig.baseUrl}/payments/$paymentId",
      ),

    );


    if(response.statusCode == 200){

      final data = jsonDecode(response.body);

      return data["status"];

    }


    throw Exception(
      "Failed to check payment status",
    );

  }



  Future<bool> approvePayment(
      String paymentId) async {


    final response = await http.put(

      Uri.parse(
        "${ApiConfig.baseUrl}/payments/$paymentId/approve",
      ),

    );


    return response.statusCode == 200;

  }


}
