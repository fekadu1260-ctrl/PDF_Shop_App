import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/app_language.dart';
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
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LanguageService.current,
      builder: (context, language, child) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.text('appTitle')),
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
            tooltip: LanguageService.text('offlineCustomers'),
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
            tooltip: LanguageService.text('waitingOrders'),
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
              decoration: InputDecoration(
                hintText: LanguageService.text('searchPdfs'),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Buy PDF'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OfflineCustomersScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: Text(
                      LanguageService.text('offlineCustomers'),
                    ),
                  ),
                ),
              ],
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
                  return Center(
                    child: Text(LanguageService.text('noPdfs')),
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
                  return Center(
                    child: Text(LanguageService.text('noMatchingPdfs')),
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
      },
    );
  }
}
