class OrderItem {
  final int? id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final String? productImage;

  OrderItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'] ?? json['product_id'] ?? 0,
      productName: json['productName'] ?? json['product_name'] ?? '',
      price: _parseDouble(json['price']),
      quantity: json['quantity'] ?? 1,
      subtotal: _parseDouble(json['subtotal']),
      productImage: json['productImage'] ?? json['product_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      if (productImage != null) 'productImage': productImage,
    };
  }

  OrderItem copyWith({
    int? id,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    double? subtotal,
    String? productImage,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      productImage: productImage ?? this.productImage,
    );
  }

  @override
  String toString() {
    return 'OrderItem(id: $id, productId: $productId, productName: $productName, quantity: $quantity, subtotal: $subtotal)';
  }

  // Helper method to parse double from string or number
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}