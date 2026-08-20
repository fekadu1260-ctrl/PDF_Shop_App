import 'package:flutter/material.dart';

import 'pdf_list.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Civil Engineering 🏗️',
      'University Notes 🎓',
      'Exam Preparation 📝',
      'Programming 💻',
      'Construction Materials 📚',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Categories'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: Text(categories[index]),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfListPage(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
