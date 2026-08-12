import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/order_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Try to upload any offline orders that are waiting.
  // If there is no internet, the app continues normally.
  try {
    await OrderSyncService.instance.syncWaitingOrders();
  } catch (_) {
    // Offline mode: ignore sync errors.
  }

  runApp(const PdfShopApp());
}

class PdfShopApp extends StatelessWidget {
  const PdfShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}
