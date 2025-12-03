import 'package:cloud_firestore/cloud_firestore.dart';

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
      'foodId': foodId,
      'foodName': foodName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      foodId: data['foodId'] ?? '',
      foodName: data['foodName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
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
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (item) => CartItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
