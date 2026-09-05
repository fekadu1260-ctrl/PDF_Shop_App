import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final accessCodeController = TextEditingController();
  final AuthService authService = AuthService();

  bool loading = false;

  String _normalizePhone(String value) {
    var phone = value.trim().replaceAll(RegExp(r'[\s\-()]'), '');

    // Ethiopian local format:
    // 0912345678 -> +251912345678
    if (phone.startsWith('09') && phone.length == 10) {
      phone = '+251${phone.substring(1)}';
    }

    // Ethiopian format without leading zero:
    // 912345678 -> +251912345678
    else if (RegExp(r'^9\d{8}$').hasMatch(phone)) {
      phone = '+251$phone';
    }

    // International format:
    // 00251912345678 -> +251912345678
    else if (phone.startsWith('00')) {
      phone = '+${phone.substring(2)}';
    }

    return phone;
  }

  Future<void> login() async {
    final phone = _normalizePhone(phoneController.text);
    final accessCode = accessCodeController.text.trim();

    if (!RegExp(r'^\+2519\d{8}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid Ethiopian phone number, for example 0912345678.',
          ),
        ),
      );
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(accessCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the 6-digit access code.'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await authService.signInCustomer(
        phoneNumber: phone,
        accessCode: accessCode,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    accessCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Shop Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.phone_android,
              size: 90,
            ),
            const SizedBox(height: 20),
            const Text(
              'Customer Login',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your phone number and access code to continue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              enabled: !loading,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '0912345678',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: accessCodeController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              enabled: !loading,
              decoration: const InputDecoration(
                labelText: 'Access Code',
                hintText: '6-digit access code',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : login,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  loading ? 'Logging in...' : 'Login',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
