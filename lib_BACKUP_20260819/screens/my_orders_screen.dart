import 'package:flutter/material.dart';
import '../services/order_service.dart';

final OrderService orderService = OrderService();

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Purchases"),
      ),
      body: FutureBuilder(
        future: orderService.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading orders: ${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No purchases found."),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(
                    order["pdfId"].toString(),
                  ),
                  subtitle: Text(
                    "Status: ${order["status"]}",
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
