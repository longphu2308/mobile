import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String? fullName;
  final String? phone;
  final String role; // 'user' hoặc 'owner'
  final String? address; // địa chỉ mặc định cho user
  final String? restaurantId; // chỉ nếu role == 'owner'
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    this.fullName,
    this.phone,
    this.role = 'user',
    this.address,
    this.restaurantId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Firestore document sang model
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      userId: documentId,
      email: data['email'] ?? '',
      fullName: data['fullName'],
      phone: data['phone'],
      role: data['role'] ?? 'user',
      address: data['address'],
      restaurantId: data['restaurantId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'address': address,
      'restaurantId': restaurantId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // Copy with method để tạo bản sao với một số field thay đổi
  UserModel copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    String? address,
    String? restaurantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
