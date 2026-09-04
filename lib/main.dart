import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';
import 'services/order_sync_service.dart';
import 'services/update_service.dart';

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
      title: 'GREAT STORE',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: const Color(0xFFE8F8FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
      ),
      home: const StartupScreen(),
    );
  }
}


class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    final update = await UpdateService.checkForUpdate();

    if (!mounted || update == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !update.forceUpdate,
      builder: (context) {
        return PopScope(
          canPop: !update.forceUpdate,
          child: AlertDialog(
            title: const Text('New version available'),
            content: Text(update.message),
            actions: [
              if (!update.forceUpdate)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Later'),
                ),
              ElevatedButton(
                onPressed: () async {
                  await UpdateService.openUpdate(update);
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFFE8F8FF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 90,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),

                const Text(
                  'GREAT STORE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 45),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: const Text(
                      'CUSTOMER LOGIN',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text(
                      'ADMIN LOGIN',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
