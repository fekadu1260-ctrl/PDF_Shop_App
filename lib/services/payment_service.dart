import 'dart:convert';
import 'package:http/http.dart' as http;


class PaymentService {


  Future<bool> createPayment({

    required String userId,
    required String pdfId,
    required double amount,

  }) async {


    final response = await http.post(

      Uri.parse(
        "http://localhost:3000/payments",
      ),


      headers: {

        "Content-Type": "application/json",

      },


      body: jsonEncode({

        "userId": userId,

        "pdfId": pdfId,

        "amount": amount,

        "status": "pending",

      }),

    );


    return response.statusCode == 200 ||
        response.statusCode == 201;

  }



  Future<String> checkPaymentStatus(
      String paymentId) async {


    final response = await http.get(

      Uri.parse(
        "http://localhost:3000/payments/$paymentId",
      ),

    );


    if(response.statusCode == 200){

      final data = jsonDecode(
        response.body,
      );


      return data['status'];

    }


    return "pending";

  }


}
Future<bool> approvePayment(
    String paymentId) async {


  final response = await http.put(

    Uri.parse(
      "http://localhost:3000/payments/$paymentId/approve",
    ),

  );


  return response.statusCode == 200;

}
