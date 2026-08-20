import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/offline_customer_service.dart';

class OfflineCustomersScreen extends StatefulWidget {
  const OfflineCustomersScreen({super.key});

  @override
  State<OfflineCustomersScreen> createState() => _OfflineCustomersScreenState();
}

class _OfflineCustomersScreenState extends State<OfflineCustomersScreen> {
  final OfflineCustomerService _service = OfflineCustomerService.instance;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  List<UserModel> _customers = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final customers = await _service.getCustomers();

    if (!mounted) return;

    setState(() {
      _customers = customers;
      _loading = false;
    });
  }

  Future<void> _addCustomer() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter customer name and phone number.',
          ),
        ),
      );
      return;
    }

    await _service.addCustomer(
      name: name,
      phone: phone,
    );

    _nameController.clear();
    _phoneController.clear();

    await _loadCustomers();

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customer saved offline successfully.'),
      ),
    );
  }

  void _showAddCustomerDialog() {
    _nameController.clear();
    _phoneController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addCustomer,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Customers'),
        actions: [
          IconButton(
            onPressed: _loadCustomers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _customers.isEmpty
              ? const Center(
                  child: Text(
                    'No customers yet.\n\n'
                    'You can add customers even without internet.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          customer.name.isEmpty
                              ? 'Unnamed Customer'
                              : customer.name,
                        ),
                        subtitle: Text(
                          customer.phone,
                        ),
                        trailing: const Icon(
                          Icons.cloud_off,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
