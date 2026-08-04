|import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const PdfShopApp());
}

chome: const LoginScreen(),home: const LoginScreen(),import 'screens/login_screen.dart';lass PdfShopApp extends StatelessWidget {
  const PdfShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Shop'),
        ),
        body: const Center(
          child: Text(
            'Welcome to PDF Shop',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
