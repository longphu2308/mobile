/// Enum cho trạng thái đơn hàng
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  delivering,
  delivered,
  cancelled;

  static OrderStatus fromString(String? status) {
    switch (status) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready_for_pickup':
        return OrderStatus.readyForPickup;
      case 'delivering':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.readyForPickup:
        return 'ready_for_pickup';
      case OrderStatus.delivering:
        return 'delivering';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.readyForPickup:
        return 'Sẵn sàng giao';
      case OrderStatus.delivering:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

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

  double get totalPrice => price * quantity;
}

class OrderModel {
  final String id;
  final String userId;
  final String restaurantId;
  final String? shipperId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String paymentMethod;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.shipperId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Supabase data sang model
  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['user_id'] ?? '',
      restaurantId: data['restaurant_id'] ?? '',
      shipperId: data['shipper_id'],
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      status: OrderStatus.fromString(data['status']),
      deliveryAddress: data['delivery_address'] ?? '',
      deliveryLatitude: data['delivery_latitude']?.toDouble(),
      deliveryLongitude: data['delivery_longitude']?.toDouble(),
      paymentMethod: data['payment_method'] ?? 'cash',
      note: data['note'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Supabase
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'restaurant_id': restaurantId,
      'shipper_id': shipperId,
      'items': items.map((item) => item.toMap()).toList(),
      'total_amount': totalAmount,
      'status': status.value,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
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
    String? shipperId,
    List<OrderItemModel>? items,
    double? totalAmount,
    OrderStatus? status,
    String? deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? paymentMethod,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      shipperId: shipperId ?? this.shipperId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Kiểm tra đơn hàng có thể hủy không
  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  /// Kiểm tra đơn hàng đang xử lý
  bool get isProcessing =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  /// Kiểm tra đơn hàng đã hoàn thành
  bool get isCompleted => status == OrderStatus.delivered;
}
