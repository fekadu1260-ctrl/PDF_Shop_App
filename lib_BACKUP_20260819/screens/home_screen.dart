import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/pdf_service.dart';
import 'category_screen.dart';
import 'pdf_details_screen.dart';
import 'profile_screen.dart';
import 'offline_customers_screen.dart';
import 'waiting_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PdfService pdfService = PdfService();
  final AuthService authService = AuthService();

  late Future<List<dynamic>> pdfs;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    pdfs = pdfService.fetchPdfs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Offline Customers',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OfflineCustomersScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Waiting Orders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WaitingOrdersScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final navigator = Navigator.of(context);

              authService.logout().then((_) {
                if (!mounted) return;

                navigator.popUntil(
                  (route) => route.isFirst,
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search PDFs...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: pdfs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No PDFs found'),
                  );
                }

                final filtered = snapshot.data!
                    .where(
                      (pdf) => pdf.title.toString().toLowerCase().contains(
                            searchText.toLowerCase(),
                          ),
                    )
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No matching PDFs'),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final pdf = filtered[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.picture_as_pdf,
                        ),
                        title: Text(pdf.title),
                        subtitle: Text(
                          '${pdf.price} Birr',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfDetailsScreen(
                                pdf: pdf,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
