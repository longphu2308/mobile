class FoodModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category; // 'appetizer', 'main', 'dessert', 'drink', 'combo'
  final bool available;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.available,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Supabase data sang model
  factory FoodModel.fromMap(Map<String, dynamic> data, String documentId) {
    // Helper function to safely parse price from String or num
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return FoodModel(
      id: data['food_id'] ?? documentId,
      restaurantId: data['restaurant_id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: parsePrice(data['price']),
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? '',
      available: data['available'] ?? true,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Supabase (snake_case)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'available': available,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    // Only include food_id if it's not empty (for updates)
    // When creating new food, let the database generate the UUID
    if (id.isNotEmpty) {
      map['food_id'] = id;
    }
    return map;
  }

  FoodModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? available,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      available: available ?? this.available,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
