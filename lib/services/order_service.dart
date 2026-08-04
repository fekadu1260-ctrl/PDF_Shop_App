Future<List<dynamic>> fetchOrders() async {

  final response = await http.get(
    Uri.parse("http://localhost:3000/orders"),
  );

Future<bool> hasPurchased(String userId, String pdfId) async {

  final orders = await fetchOrders();

  for (final order in orders) {
    if (order["userId"] == userId &&
        order["pdfId"] == pdfId &&
        order["status"] == "paid") {
      return true;
    }
  }

  return false;
}  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load orders");
  }
}import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class OrderService {

  Future<OrderModel> createOrder({
    required String userId,
    required String pdfId,
    required double amount,
  }) async {

    final response = await http.post(

      Uri.parse("http://localhost:3000/orders"),

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


    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      return OrderModel.fromJson(
        jsonDecode(response.body),
      );

    } else {

      throw Exception(
        "Order creation failed",
      );

    }
  }
}
