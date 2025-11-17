import 'package:cloud_firestore/cloud_firestore.dart';

class PromoModel {
  final String id;
  final String code;
  final String description;
  final double discount; // phần trăm hoặc fixed amount
  final String type; // 'user', 'owner', hoặc 'both'
  final String? restaurantId; // optional, nếu chỉ áp dụng cho quán cụ thể
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final int usedCount; // số lần đã sử dụng
  final DateTime createdAt;
  final DateTime updatedAt;

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
  });

  // Chuyển từ Firestore document sang model
  factory PromoModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PromoModel(
      id: documentId,
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      discount: (data['discount'] ?? 0).toDouble(),
      type: data['type'] ?? 'user',
      restaurantId: data['restaurantId'],
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      active: data['active'] ?? true,
      usedCount: data['usedCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
      'discount': discount,
      'type': type,
      'restaurantId': restaurantId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'active': active,
      'usedCount': usedCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  PromoModel copyWith({
    String? id,
    String? code,
    String? description,
    double? discount,
    String? type,
    String? restaurantId,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
    int? usedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
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
    );
  }

  // Kiểm tra promo còn hiệu lực
  bool get isValid {
    final now = DateTime.now();
    return active && now.isAfter(startDate) && now.isBefore(endDate);
  }
}
