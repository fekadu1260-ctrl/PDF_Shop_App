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
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
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
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> choosePdf() async {
    final file = await pickerService.pickPdf();

    if (!mounted) return;

    setState(() {
      selectedFile = file;
    });
  }

  Future<void> uploadPdf() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final category = categoryController.text.trim();
    final priceText = priceController.text.trim();
    final url = urlController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        category.isEmpty ||
        priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter title, description, category and price.',
          ),
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);

    if (price == null || price < 0) {
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

      // If a local PDF was selected, upload it to Firebase Storage first.
      if (selectedFile != null) {
        fileUrl = await storageService.uploadPdf(selectedFile!);
      }

      if (fileUrl.isEmpty) {
        throw Exception(
          'Please choose a PDF or enter a PDF URL.',
        );
      }

      final success = await service.uploadPdf(
        title: title,
        description: description,
        price: price,
        category: category,
        fileUrl: fileUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'PDF uploaded successfully'
                : 'PDF upload failed',
          ),
        ),
      );

      if (success) {
        titleController.clear();
        descriptionController.clear();
        categoryController.clear();
        priceController.clear();
        urlController.clear();

        setState(() {
          selectedFile = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'PDF Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Example: Engineering',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (Birr)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'PDF URL (optional)',
                hintText: 'Leave empty when uploading a PDF file',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (selectedFile != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'PDF file selected and ready for upload.',
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : choosePdf,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose PDF'),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : uploadPdf,
                icon: const Icon(Icons.cloud_upload),
                label: Text(
                  isUploading ? 'Uploading...' : 'Upload PDF',
                ),
              ),
            ),

            if (isUploading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
