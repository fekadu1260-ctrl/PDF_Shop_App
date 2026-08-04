import 'package:flutter/material.dart';


class AdminPaymentScreen extends StatelessWidget {

  const AdminPaymentScreen({super.key});
final PaymentService paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
import '../services/payment_service.dart';
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Payment Verification",
        ),
      ),


      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          Card(

            child: ListTile(

              title: const Text(
                "User: Customer",
              ),

              subtitle: const Text(
                "Status: Pending",
              ),


              trailing: ElevatedButton(

                onPressed: () {

                  // Change pending to paid

                },


                child: const Text(
                  "Approve",
                ),

              ),

            ),

          ),

        ],

      ),

    );

  }

}
ElevatedButton(

  onPressed: () async {

    final success =
        await paymentService.approvePayment(
          "PAYMENT_ID",
        );


    if(success){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Payment approved",
          ),
        ),

      );

    }

  },


  child: const Text(
    "Approve",
  ),

)
