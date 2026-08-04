price: double.tryParse(json['price'].toString()) ?? 0,class PdfModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String fileUrl;

  PdfModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.fileUrl,
  });

  factory PdfModel.fromJson(Map<String, dynamic> json) {
    return PdfModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      fileUrl: json['fileUrl'] ?? '',
    );
  }
}
