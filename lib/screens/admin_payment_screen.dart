import 'package:flutter/material.dart';


class AdminPaymentScreen extends StatelessWidget {

  const AdminPaymentScreen({super.key});


  @override
  Widget build(BuildContext context) {

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
