import 'package:flutter/material.dart';
import 'screens/login.dart';

void main() {
  runApp(const PDFShopApp());
}

class PDFShopApp extends StatelessWidget {
  const PDFShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "PDF Shop",
      home: const LoginPage(),
    );
  }
}o

