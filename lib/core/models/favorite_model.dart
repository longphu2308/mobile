import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String restaurantId;
  final String? restaurantName;
  final String? restaurantImageUrl;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.restaurantName,
    this.restaurantImageUrl,
    required this.createdAt,
  });

  // Chuyển từ Firestore document sang model
  factory FavoriteModel.fromMap(Map<String, dynamic> data, String documentId) {
    return FavoriteModel(
      id: documentId,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'],
      restaurantImageUrl: data['restaurantImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantImageUrl': restaurantImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    String? restaurantImageUrl,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantImageUrl: restaurantImageUrl ?? this.restaurantImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


