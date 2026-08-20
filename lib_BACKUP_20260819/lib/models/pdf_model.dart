class PdfModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String fileUrl;

  PdfModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.fileUrl,
  });

  factory PdfModel.fromJson(Map<String, dynamic> json) {
    return PdfModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      category: json['category'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
    );
  }
}
