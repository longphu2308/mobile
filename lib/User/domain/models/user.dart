import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String? fullName;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    this.fullName,
    this.phone,
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
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  // Copy with method để tạo bản sao với một số field thay đổi
  UserModel copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
