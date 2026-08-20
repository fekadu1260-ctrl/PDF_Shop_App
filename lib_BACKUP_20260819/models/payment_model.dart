class PaymentModel {
  final String id;
  final String userId;
  final String pdfId;
  final double amount;
  final String status;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.pdfId,
    required this.amount,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      pdfId: json['pdfId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
    );
  }
}
