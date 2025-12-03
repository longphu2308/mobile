import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String description;
  final String imageUrl;
  final String status; // 'open' hoặc 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Firestore document sang model
  factory RestaurantModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return RestaurantModel(
      id: documentId,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'closed',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    String? description,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
