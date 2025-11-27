import 'package:cloud_firestore/cloud_firestore.dart';

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
      userId: data['userId'] ?? '',
      foodId: data['foodId'] ?? '',
      foodName: data['foodName'] ?? '',
      foodImageUrl: data['foodImageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      restaurantId: data['restaurantId'],
      restaurantName: data['restaurantName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foodId': foodId,
      'foodName': foodName,
      'foodImageUrl': foodImageUrl,
      'price': price,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'createdAt': Timestamp.fromDate(createdAt),
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


