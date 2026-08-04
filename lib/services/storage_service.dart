import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';


class StorageService {


  Future<String> uploadPdf(
      File file) async {


    final fileName =
        DateTime.now()
            .millisecondsSinceEpoch
            .toString();


    final ref = FirebaseStorage
        .instance
        .ref()
        .child(
          "pdfs/$fileName.pdf",
        );


    await ref.putFile(file);


    return await ref.getDownloadURL();

  }

}
