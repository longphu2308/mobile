class CartItemModel {
  final String foodId;
  final String foodName;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItemModel({
    required this.foodId,
    required this.foodName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'price': price,
      'image_url': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      foodId: data['food_id'] ?? '',
      foodName: data['food_name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['image_url'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  double get totalPrice => price * quantity;
}

class CartModel {
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<CartItemModel> items;
  final DateTime updatedAt;

  CartModel({
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.updatedAt,
  });

  // Chuyển từ Firestore document sang model
  factory CartModel.fromMap(Map<String, dynamic> data, String userId) {
    return CartModel(
      userId: userId,
      restaurantId: data['restaurant_id'] ?? '',
      restaurantName: data['restaurant_name'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (item) => CartItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'items': items.map((item) => item.toMap()).toList(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
