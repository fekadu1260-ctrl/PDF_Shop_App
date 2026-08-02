import 'package:flutter/material.dart';
import 'categories.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Shop"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CategoriesPage(),
    ),
  );
},        children: [
          const Text(
            "Welcome!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("Engineering PDFs"),
              subtitle: const Text("Civil, Electrical, Mechanical"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.school),
              title: const Text("University Notes"),
              subtitle: const Text("Lecture notes and exams"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.download),
              title: const Text("My Downloads"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My Profile"),
            ),
          ),
        ],
      ),
    );
  }
}

onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CategoriesPage(),
    ),
  );
},

