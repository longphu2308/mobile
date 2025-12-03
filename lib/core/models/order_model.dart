import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String foodId;
  final String foodName;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      foodId: data['foodId'] ?? '',
      foodName: data['foodName'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String restaurantId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status; // 'pending', 'preparing', 'delivered', 'cancelled'
  final String deliveryAddress;
  final String paymentMethod; // 'cash', 'card', 'momo', etc.
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Firestore document sang model
  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      deliveryAddress: data['deliveryAddress'] ?? '',
      paymentMethod: data['paymentMethod'] ?? 'cash',
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    List<OrderItemModel>? items,
    double? totalAmount,
    String? status,
    String? deliveryAddress,
    String? paymentMethod,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
