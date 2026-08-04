import 'package:flutter/material.dart';
import 'admin_upload_screen.dart';


class AdminDashboard extends StatelessWidget {

  const AdminDashboard({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),


      body: Center(

        child: ElevatedButton(

          onPressed: () {

            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                const AdminUploadScreen(),

              ),

            );

          },


          child: const Text(
            "Add New PDF",
          ),

        ),

      ),

    );

  }

}
