
class Product {
  final String id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double discount;
  final int stock;
  final String sku;
  final String status;
  final String category;
  final String brand;
  final List<Map<String, String>> images; // List of image objects with path and altText
  final String createdAt;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.discount,
    required this.stock,
    required this.sku,
    required this.status,
    required this.category,
    required this.brand,
    required this.images,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse images array
    List<Map<String, String>> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img is Map<String, dynamic>) {
          parsedImages.add({
            'path': img['path'] ?? '',
            'altText': img['altText'] ?? '',
          });
        }
      }
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is String) ? double.tryParse(json['price']) ?? 0.0 :
             (json['price'] is int) ? (json['price'] as int).toDouble() :
             (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      discount: (json['discount'] is String) ? double.tryParse(json['discount']) ?? 0.0 :
               (json['discount'] is int) ? (json['discount'] as int).toDouble() :
               (json['discount'] is num) ? (json['discount'] as num).toDouble() : 0.0,
      stock: json['stock'] ?? 0,
      sku: json['sku'] ?? '',
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      images: parsedImages,
      createdAt: json['createdAt'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Getter for the primary image path
  String get primaryImagePath {
    if (images.isNotEmpty) {
      return images[0]['path'] ?? '';
    }
    return '';
  }
}
