class Carousel {
  final int id;
  final String name;
  final String imageUrl;
  final int? targetCategoryId;
  final int priority;
  final bool isActive;

  Carousel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.targetCategoryId,
    required this.priority,
    required this.isActive,
  });

  factory Carousel.fromJson(Map<String, dynamic> json) {
    return Carousel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      targetCategoryId: json['target_category_id'] is int ? json['target_category_id'] : int.tryParse(json['target_category_id']?.toString() ?? ''),
      priority: json['priority'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'target_category_id': targetCategoryId,
      'priority': priority,
      'is_active': isActive,
    };
  }
}
