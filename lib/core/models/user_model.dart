class UserModel {
  final String userId;
  final String email;
  final String? fullName;
  final String? phone;
  final String role; // 'user' hoặc 'owner'
  final String? address; // địa chỉ mặc định cho user
  final String? restaurantId; // chỉ nếu role == 'owner'
  final String? avatarUrl; // URL ảnh đại diện
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
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Supabase data sang model
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      userId: documentId,
      email: data['email'] ?? '',
      fullName: data['full_name'],
      phone: data['phone'],
      role: data['role'] ?? 'user',
      address: data['address'],
      restaurantId: data['restaurant_id'],
      avatarUrl: data['profile_image_url'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  // Chuyển model sang map để lưu vào Supabase (snake_case)
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'address': address,
      'restaurant_id': restaurantId,
      'profile_image_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
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
    String? avatarUrl,
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
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
