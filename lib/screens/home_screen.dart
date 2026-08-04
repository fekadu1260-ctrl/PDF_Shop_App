import 'package:flutter/material.dart';
import '../models/pdf_model.dart';
import '../services/pdf_service.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'my_orders_screen.dart';
import 'pdf_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final PdfService pdfService = PdfService();
  final AuthService authService = AuthService();

  late Future<List<dynamic>> pdfs;

  String searchText = "";

  @override
  void initState() {
    super.initState();
    pdfs = pdfService.fetchPdfs();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("PDF Shop"),

        actions: [

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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );
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
                hintText: "Search PDFs...",
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

                if(snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                }


                if(!snapshot.hasData ||
                    snapshot.data!.isEmpty) {

                  return const Center(
                    child: Text("No PDFs found"),
                  );

                }


                final filtered = snapshot.data!
                    .where((pdf) =>
                    pdf['title']
                        .toString()
                        .toLowerCase()
                        .contains(
                        searchText.toLowerCase()))
                    .toList();


                return ListView.builder(

                  itemCount: filtered.length,

                  itemBuilder: (context,index){

                    final pdf =
                    PdfModel.fromJson(filtered[index]);


                    return Card(

                      child: ListTile(

                        title: Text(pdf.title),

                        subtitle:
                        Text("${pdf.price} Birr"),


                        trailing:
                        const Icon(
                          Icons.arrow_forward,
                        ),


                        onTap: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  PdfDetailsScreen(
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
