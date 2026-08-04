import '../services/order_service.dart';final OrderService orderService = OrderService();import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(body: FutureBuilder(
  future: orderService.fetchOrders(),
  builder: (context, snapshot) {

    if (!snapshot.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final orders = snapshot.data!;

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {

        final order = orders[index];

        return ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(order["pdfId"].toString()),
          subtitle: Text(order["status"].toString()),
        );
      },
    );
  },
),
        title: const Text("My Purchases"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Sample PDF"),
              subtitle: const Text("Status: Pending Payment"),
              trailing: const Icon(Icons.arrow_forward),
            ),
          ),

        ],
      ),
    );
  }
}
