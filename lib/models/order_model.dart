class OrderModel {
  final String id;
  final String userId;
  final String pdfId;
  final double amount;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.pdfId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });


  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      pdfId: json['pdfId'] ?? '',
      amount: double.tryParse(
        json['amount'].toString(),
      ) ?? 0,

      status: json['status'] ?? 'pending',

      createdAt: DateTime.tryParse(
        json['createdAt'].toString(),
      ) ?? DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pdfId': pdfId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
