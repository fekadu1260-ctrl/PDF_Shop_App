import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _loading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _isAdmin = false;
      });

      return;
    }

    try {
      // Force-refresh the Firebase ID token so the latest
      // custom claims (admin: true) are available.
      final tokenResult = await user.getIdTokenResult(true);

      final claims = tokenResult.claims;

      if (!mounted) return;

      setState(() {
        _isAdmin = claims?['admin'] == true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _isAdmin = false;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          const Center(
            child: Icon(
              Icons.account_circle,
              size: 90,
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(user?.email ?? "No email"),
            ),
          ),

          const SizedBox(height: 12),

          if (_loading)
            const Card(
              child: ListTile(
                leading: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
                title: Text("Checking account permissions..."),
              ),
            ),

          if (!_loading && _isAdmin)
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text("Admin Dashboard"),
                subtitle: const Text(
                  "Manage PDFs, payments and orders",
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPage(),
                    ),
                  );
                },
              ),
            ),

          if (!_loading && !_isAdmin)
            const Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text("Customer Account"),
                subtitle: Text("Standard PDF Shop account"),
              ),
            ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
            ),
          ),
        ],
      ),
    );
  }
}
