class PromoModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final double discountPercent; // phần trăm giảm giá
  final double? maxDiscountAmount; // giảm tối đa
  final double minOrderAmount; // đơn tối thiểu
  final String type; // 'user', 'owner', hoặc 'both'
  final String? restaurantId; // optional, nếu chỉ áp dụng cho quán cụ thể
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final int usageLimit; // giới hạn số lần sử dụng
  final int usedCount; // số lần đã sử dụng
  final DateTime createdAt;
  final DateTime updatedAt;

  PromoModel({
    required this.id,
    required this.code,
    this.name = '',
    required this.description,
    required this.discountPercent,
    this.maxDiscountAmount,
    this.minOrderAmount = 0,
    required this.type,
    this.restaurantId,
    required this.startDate,
    required this.endDate,
    required this.active,
    this.usageLimit = 999,
    this.usedCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Alias getter for backward compatibility
  double get discount => discountPercent;

  // Chuyển từ Supabase data sang model
  factory PromoModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PromoModel(
      id: documentId,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      discountPercent: (data['discount_percent'] ?? data['discount'] ?? 0).toDouble(),
      maxDiscountAmount: data['max_discount_amount'] != null 
          ? (data['max_discount_amount']).toDouble() 
          : null,
      minOrderAmount: (data['min_order_amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'user',
      restaurantId: data['restaurant_id'],
      startDate: data['start_date'] != null
          ? DateTime.parse(data['start_date'])
          : DateTime.now(),
      endDate: data['end_date'] != null
          ? DateTime.parse(data['end_date'])
          : DateTime.now(),
      active: data['active'] ?? true,
      usageLimit: data['usage_limit'] ?? 999,
      usedCount: data['used_count'] ?? 0,
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
      'code': code,
      'name': name,
      'description': description,
      'discount_percent': discountPercent,
      'max_discount_amount': maxDiscountAmount,
      'min_order_amount': minOrderAmount,
      'type': type,
      'restaurant_id': restaurantId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'active': active,
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  PromoModel copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    double? discountPercent,
    double? maxDiscountAmount,
    double? minOrderAmount,
    String? type,
    String? restaurantId,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
    int? usageLimit,
    int? usedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromoModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      type: type ?? this.type,
      restaurantId: restaurantId ?? this.restaurantId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Kiểm tra promo còn hiệu lực
  bool get isValid {
    final now = DateTime.now();
    return active && now.isAfter(startDate) && now.isBefore(endDate);
  }

  // Kiểm tra đã hết hạn chưa
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  // Kiểm tra đã đạt giới hạn sử dụng chưa
  bool get isUsageLimitReached {
    return usedCount >= usageLimit;
  }
}
