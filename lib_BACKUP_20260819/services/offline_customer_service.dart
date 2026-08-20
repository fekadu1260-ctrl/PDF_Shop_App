import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/user_model.dart';

class OfflineCustomerService {
  static final OfflineCustomerService instance =
      OfflineCustomerService._internal();

  OfflineCustomerService._internal();

  final List<UserModel> _customers = [];

  Future<File> _getStorageFile() async {
    final directory = await getApplicationDocumentsDirectory();

    final dataDirectory = Directory(
      '${directory.path}/pdf_shop_data',
    );

    if (!await dataDirectory.exists()) {
      await dataDirectory.create(recursive: true);
    }

    return File(
      '${dataDirectory.path}/offline_customers.json',
    );
  }

  Future<void> _saveCustomers() async {
    final file = await _getStorageFile();

    await file.writeAsString(
      jsonEncode(
        _customers.map((customer) => customer.toJson()).toList(),
      ),
    );
  }

  Future<void> _loadCustomers() async {
    try {
      final file = await _getStorageFile();

      if (!await file.exists()) {
        return;
      }

      final content = await file.readAsString();

      if (content.trim().isEmpty) {
        return;
      }

      final decoded = jsonDecode(content);

      if (decoded is! List) {
        return;
      }

      _customers
        ..clear()
        ..addAll(
          decoded.whereType<Map<String, dynamic>>().map(UserModel.fromJson),
        );
    } catch (_) {}
  }

  Future<UserModel> addCustomer({
    required String name,
    required String phone,
  }) async {
    await _loadCustomers();

    final customer = UserModel(
      id: 'LOCAL-${DateTime.now().millisecondsSinceEpoch}',
      email: '',
      role: 'user',
      name: name,
      phone: phone,
      isOffline: true,
    );

    _customers.add(customer);

    await _saveCustomers();

    return customer;
  }

  Future<List<UserModel>> getCustomers() async {
    await _loadCustomers();

    return List.unmodifiable(_customers);
  }

  Future<UserModel?> findByPhone(String phone) async {
    await _loadCustomers();

    for (final customer in _customers) {
      if (customer.phone == phone) {
        return customer;
      }
    }

    return null;
  }

  Future<void> removeCustomer(String id) async {
    await _loadCustomers();

    _customers.removeWhere(
      (customer) => customer.id == id,
    );

    await _saveCustomers();
  }
}
