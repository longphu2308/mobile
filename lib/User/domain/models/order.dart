import 'package:mobile/User/domain/models/cart_item.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime createdAt;
  final String status; // 'pending', 'completed', 'cancelled'

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    this.status = 'completed',
  });

  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? totalPrice,
    DateTime? createdAt,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  // Create from Map (Firebase data)
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item))
              .toList() ??
          [],
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      status: map['status'] ?? 'completed',
    );
  }
}
