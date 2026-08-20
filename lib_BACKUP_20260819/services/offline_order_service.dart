import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class OfflineOrder {
  final String id;
  final String orderNumber;
  final String userId;
  final String pdfId;
  final double amount;
  final String status;
  final String paymentReference;
  final DateTime createdAt;
  final String syncStatus;

  OfflineOrder({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.pdfId,
    required this.amount,
    required this.status,
    required this.paymentReference,
    required this.createdAt,
    required this.syncStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'pdfId': pdfId,
      'amount': amount,
      'status': status,
      'paymentReference': paymentReference,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  factory OfflineOrder.fromJson(Map<String, dynamic> json) {
    return OfflineOrder(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ??
          json['id']?.toString() ??
          '',
      userId: json['userId']?.toString() ?? '',
      pdfId: json['pdfId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      paymentReference:
          json['paymentReference']?.toString() ?? '',
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
      syncStatus: json['syncStatus']?.toString() ?? 'waiting',
    );
  }
}

class OfflineOrderService {
  static final OfflineOrderService instance =
      OfflineOrderService._internal();

  OfflineOrderService._internal();

  final List<OfflineOrder> _orders = [];

  List<OfflineOrder> get waitingOrders => List.unmodifiable(
        _orders.where(
          (order) => order.syncStatus == 'waiting',
        ),
      );

  int get waitingCount => _orders
      .where(
        (order) => order.syncStatus == 'waiting',
      )
      .length;

  String _generateOrderNumber() {
    final now = DateTime.now();

    final date =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';

    final timestamp = now.millisecondsSinceEpoch
        .toString()
        .substring(7);

    return 'PS-$date-$timestamp';
  }

  Future<OfflineOrder> createOfflineOrder({
    required String userId,
    required String pdfId,
    required double amount,
  }) async {
    await _loadOrders();

    final order = OfflineOrder(
      id: 'OFF-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: _generateOrderNumber(),
      userId: userId,
      pdfId: pdfId,
      amount: amount,
      status: 'pending',
      paymentReference: '',
      createdAt: DateTime.now(),
      syncStatus: 'waiting',
    );

    _orders.add(order);

    await _saveOrders();

    return order;
  }

  Future<List<OfflineOrder>> getWaitingOrders() async {
    await _loadOrders();

    return List.unmodifiable(
      _orders.where(
        (order) => order.syncStatus == 'waiting',
      ),
    );
  }

  Future<void> markAsSynced(String orderId) async {
    await _loadOrders();

    final index = _orders.indexWhere(
      (order) => order.id == orderId,
    );

    if (index == -1) return;

    final old = _orders[index];

    _orders[index] = OfflineOrder(
      id: old.id,
      orderNumber: old.orderNumber,
      userId: old.userId,
      pdfId: old.pdfId,
      amount: old.amount,
      status: old.status,
      paymentReference: old.paymentReference,
      createdAt: old.createdAt,
      syncStatus: 'synced',
    );

    await _saveOrders();
  }

  Future<File> _getStorageFile() async {
    final directory =
        await getApplicationDocumentsDirectory();

    final dataDirectory = Directory(
      '${directory.path}/pdf_shop_data',
    );

    if (!await dataDirectory.exists()) {
      await dataDirectory.create(recursive: true);
    }

    return File(
      '${dataDirectory.path}/offline_orders.json',
    );
  }

  Future<void> _saveOrders() async {
    try {
      final file = await _getStorageFile();

      await file.writeAsString(
        jsonEncode(
          _orders.map((order) => order.toJson()).toList(),
        ),
      );
    } catch (_) {}
  }

  Future<void> _loadOrders() async {
    try {
      final file = await _getStorageFile();

      if (!await file.exists()) return;

      final content = await file.readAsString();

      if (content.trim().isEmpty) return;

      final decoded = jsonDecode(content);

      if (decoded is! List) return;

      _orders
        ..clear()
        ..addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map(OfflineOrder.fromJson),
        );
    } catch (_) {}
  }
}
