import 'package:mobile/User/domain/models/cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime createdAt;
  final String status; // 'pending', 'completed', 'cancelled'

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    this.status = 'completed',
  });

  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? totalPrice,
    DateTime? createdAt,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

