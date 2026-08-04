import 'dart:io';
import '../services/file_picker_service.dart';
import '../services/storage_service.dart';final FilePickerService pickerService = FilePickerService();
final StorageService storageService = StorageService();

File? selectedFile;
String? uploadedUrl;import 'package:flutter/material.dart';
import '../services/admin_pdf_service.dart';


class AdminUploadScreen extends StatefulWidget {

  const AdminUploadScreen({super.key});


  @override
  State<AdminUploadScreen> createState() =>
      _AdminUploadScreenState();

}



class _AdminUploadScreenState
    extends State<AdminUploadScreen> {


  final AdminPdfService service = AdminPdfService();


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
              decoration: const InputDecoration(
                labelText: "PDF Title",
              ),
            ),



            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
              ),
            ),



            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "PDF URL",
              ),
            ),


if(selectedFile != null){

  uploadedUrl =
      await storageService.uploadPdf(
        selectedFile!,
      );

}
            const SizedBox(height:20),



            ElevatedButton(
fileUrl: uploadedUrl ?? "",
              onPressed: () async {


                final success =
                await service.uploadPdf(

                  title: titleController.text,

                  price: double.parse(
                    priceController.text,
                  ),

                  fileUrl: urlController.text,

                );



                if(success){

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(
ElevatedButton(

  onPressed: () async {

    final file = await pickerService.pickPdf();

    setState(() {

      selectedFile = file;

    });

  },

  child: const Text(
    "Choose PDF",
  ),

),
                      content: Text(
                        "PDF uploaded successfully",
                      ),

                    ),

                  );

                }


              },


              child: const Text(
                "Upload PDF",
              ),

            ),


          ],

        ),

      ),

    );

  }

}
