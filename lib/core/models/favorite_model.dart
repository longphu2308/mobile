class FavoriteModel {
  final String id;
  final String userId;
  final String foodId;
  final String foodName;
  final String foodImageUrl;
  final double price;
  final String? restaurantId;
  final String? restaurantName;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.foodName,
    required this.foodImageUrl,
    required this.price,
    this.restaurantId,
    this.restaurantName,
    required this.createdAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> data, String documentId) {
    return FavoriteModel(
      id: documentId,
      userId: data['user_id'] ?? '',
      foodId: data['food_id'] ?? '',
      foodName: data['food_name'] ?? '',
      foodImageUrl: data['food_image_url'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      restaurantId: data['restaurant_id'],
      restaurantName: data['restaurant_name'],
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'food_id': foodId,
      'food_name': foodName,
      'food_image_url': foodImageUrl,
      'price': price,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? foodId,
    String? foodName,
    String? foodImageUrl,
    double? price,
    String? restaurantId,
    String? restaurantName,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      foodImageUrl: foodImageUrl ?? this.foodImageUrl,
      price: price ?? this.price,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


