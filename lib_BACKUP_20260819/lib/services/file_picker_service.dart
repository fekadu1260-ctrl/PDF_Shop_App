import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<File?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      return File(
        result.files.single.path!,
      );
    }

    return null;
  }
}
