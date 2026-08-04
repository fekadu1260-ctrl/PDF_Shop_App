import 'package:flutter/material.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() =>
      _AdminUploadScreenState();
}


class _AdminUploadScreenState
    extends State<AdminUploadScreen> {

  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final urlController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add PDF"),
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: titleController,
              decoration:
              const InputDecoration(
                labelText: "PDF Title",
              ),
            ),


            TextField(
              controller: priceController,
              decoration:
              const InputDecoration(
                labelText: "Price",
              ),
            ),


            TextField(
              controller: urlController,
              decoration:
              const InputDecoration(
                labelText: "PDF URL",
              ),
            ),


            const SizedBox(height:20),


            ElevatedButton(

              onPressed: () {

                // Later connect Firebase/API upload

              },

              child:
              const Text("Upload PDF"),

            ),

          ],

        ),

      ),

    );

  }

}
