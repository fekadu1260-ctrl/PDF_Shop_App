import 'package:flutter/material.dart';

import '../services/admin_pdf_service.dart';
import '../services/file_picker_service.dart';
import '../services/storage_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final urlController = TextEditingController();

  final AdminPdfService service = AdminPdfService();
  final FilePickerService pickerService = FilePickerService();
  final StorageService storageService = StorageService();

  dynamic selectedFile;
  bool isUploading = false;

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> choosePdf() async {
    final file = await pickerService.pickPdf();

    if (!mounted) {
      return;
    }

    setState(() {
      selectedFile = file;
    });
  }

  Future<void> uploadPdf() async {
    final title = titleController.text.trim();
    final priceText = priceController.text.trim();
    final url = urlController.text.trim();

    if (title.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the PDF title and price.'),
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price.'),
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String fileUrl = url;

      if (selectedFile != null) {
        fileUrl = await storageService.uploadPdf(selectedFile!);
      }

      if (fileUrl.isEmpty) {
        throw Exception('Please choose a PDF or enter a PDF URL.');
      }

      final success = await service.uploadPdf(
        title: title,
        price: price,
        fileUrl: fileUrl,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'PDF uploaded successfully' : 'PDF upload failed',
          ),
        ),
      );

      if (success) {
        titleController.clear();
        priceController.clear();
        urlController.clear();

        setState(() {
          selectedFile = null;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add PDF'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'PDF Title',
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'PDF URL',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUploading ? null : choosePdf,
                child: const Text('Choose PDF'),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUploading ? null : uploadPdf,
                child: Text(
                  isUploading ? 'Uploading...' : 'Upload PDF',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
