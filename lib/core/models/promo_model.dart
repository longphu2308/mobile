class PromoModel {
  final String id;
  final String code;
  final String description;
  final int discount; // phần trăm giảm giá (integer trong DB)
  final String type; // 'order', 'delivery', 'food', 'all'
  final String? restaurantId;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final int usedCount; // số lần đã sử dụng
  final DateTime createdAt;
  final DateTime updatedAt;

  // Các trường không có trong DB nhưng UI cần (giữ cho tương thích)
  final String name;
  final double? maxDiscountAmount;
  final double minOrderAmount;
  final int usageLimit;

  PromoModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discount,
    required this.type,
    this.restaurantId,
    required this.startDate,
    required this.endDate,
    required this.active,
    this.usedCount = 0,
    required this.createdAt,
    required this.updatedAt,
    // Các trường UI (không lưu DB)
    this.name = '',
    this.maxDiscountAmount,
    this.minOrderAmount = 0,
    this.usageLimit = 999,
  });

  // Alias getter for backward compatibility
  double get discountPercent => discount.toDouble();

  // Chuyển từ Supabase data sang model
  factory PromoModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PromoModel(
      id: documentId,
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      discount: (data['discount'] ?? 0) is int 
          ? data['discount'] ?? 0 
          : (data['discount'] ?? 0).toInt(),
      type: data['type'] ?? 'delivery',
      restaurantId: data['restaurant_id'],
      startDate: data['start_date'] != null
          ? DateTime.parse(data['start_date'])
          : DateTime.now(),
      endDate: data['end_date'] != null
          ? DateTime.parse(data['end_date'])
          : DateTime.now(),
      active: data['active'] ?? true,
      usedCount: data['used_count'] ?? 0,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Supabase (chỉ các cột trong DB)
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
      'discount': discount,
      'type': type,
      'restaurant_id': restaurantId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'active': active,
      'used_count': usedCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  PromoModel copyWith({
    String? id,
    String? code,
    String? description,
    int? discount,
    String? type,
    String? restaurantId,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
    int? usedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    // UI fields
    String? name,
    double? maxDiscountAmount,
    double? minOrderAmount,
    int? usageLimit,
  }) {
    return PromoModel(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      discount: discount ?? this.discount,
      type: type ?? this.type,
      restaurantId: restaurantId ?? this.restaurantId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
      usedCount: usedCount ?? this.usedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // UI fields
      name: name ?? this.name,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      usageLimit: usageLimit ?? this.usageLimit,
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
