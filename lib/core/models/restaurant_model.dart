class RestaurantModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String description;
  final String imageUrl;
  final String phone;
  final double rating;
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
    required this.phone,
    required this.rating,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Supabase data sang model
  factory RestaurantModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return RestaurantModel(
      id: data['restaurant_id'] ?? documentId,
      ownerId: data['owner_id'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      phone: data['phone'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      status: data['status'] ?? 'closed',
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
      'restaurant_id': id,
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'description': description,
      'image_url': imageUrl,
      'phone': phone,
      'rating': rating,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    String? description,
    String? imageUrl,
    String? phone,
    double? rating,
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
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
