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
      'food_id': foodId,
      'food_name': foodName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      foodId: data['food_id'] ?? '',
      foodName: data['food_name'] ?? '',
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
      userId: data['user_id'] ?? '',
      restaurantId: data['restaurant_id'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      deliveryAddress: data['delivery_address'] ?? '',
      paymentMethod: data['payment_method'] ?? 'cash',
      note: data['note'],
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'restaurant_id': restaurantId,
      'items': items.map((item) => item.toMap()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
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
