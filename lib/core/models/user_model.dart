/// Enum cho role của user
enum UserRole {
  user,
  owner,
  shipper;

  static UserRole fromString(String? role) {
    switch (role) {
      case 'owner':
        return UserRole.owner;
      case 'shipper':
        return UserRole.shipper;
      default:
        return UserRole.user;
    }
  }

  String get value {
    switch (this) {
      case UserRole.owner:
        return 'owner';
      case UserRole.shipper:
        return 'shipper';
      default:
        return 'user';
    }
  }
}

/// Model cho bảng users (chỉ auth info)
class UserModel {
  final String userId;
  final String email;
  final UserRole role;
  final String? restaurantId; // chỉ nếu role == 'owner'
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    this.role = UserRole.user,
    this.restaurantId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Chuyển từ Supabase data sang model
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      userId: documentId,
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role']),
      restaurantId: data['restaurant_id'],
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
      'role': role.value,
      'restaurant_id': restaurantId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Copy with method để tạo bản sao với một số field thay đổi
  UserModel copyWith({
    String? userId,
    String? email,
    UserRole? role,
    String? restaurantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOwner => role == UserRole.owner;
  bool get isShipper => role == UserRole.shipper;
  bool get isUser => role == UserRole.user;
}

/// Model cho bảng user_profiles (thông tin profile)
class UserProfileModel {
  final String profileId;
  final String userId;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.profileId,
    required this.userId,
    this.fullName,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> data) {
    return UserProfileModel(
      profileId: data['profile_id'] ?? '',
      userId: data['user_id'] ?? '',
      fullName: data['full_name'],
      phone: data['phone'],
      avatarUrl: data['avatar_url'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Dùng khi insert mới (không cần profile_id)
  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }

  UserProfileModel copyWith({
    String? profileId,
    String? userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      profileId: profileId ?? this.profileId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Enum cho label địa chỉ
enum AddressLabel {
  home,
  work,
  other;

  static AddressLabel fromString(String? label) {
    switch (label) {
      case 'work':
        return AddressLabel.work;
      case 'other':
        return AddressLabel.other;
      default:
        return AddressLabel.home;
    }
  }

  String get value {
    switch (this) {
      case AddressLabel.work:
        return 'work';
      case AddressLabel.other:
        return 'other';
      default:
        return 'home';
    }
  }

  String get displayName {
    switch (this) {
      case AddressLabel.home:
        return 'Nhà';
      case AddressLabel.work:
        return 'Công ty';
      case AddressLabel.other:
        return 'Khác';
    }
  }
}

/// Model cho bảng user_addresses (địa chỉ)
class UserAddressModel {
  final String addressId;
  final String userId;
  final AddressLabel label;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAddressModel({
    required this.addressId,
    required this.userId,
    this.label = AddressLabel.home,
    required this.address,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAddressModel.fromMap(Map<String, dynamic> data) {
    return UserAddressModel(
      addressId: data['address_id'] ?? '',
      userId: data['user_id'] ?? '',
      label: AddressLabel.fromString(data['label']),
      address: data['address'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      isDefault: data['is_default'] ?? false,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address_id': addressId,
      'user_id': userId,
      'label': label.value,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Dùng khi insert mới (không cần address_id)
  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'label': label.value,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  UserAddressModel copyWith({
    String? addressId,
    String? userId,
    AddressLabel? label,
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAddressModel(
      addressId: addressId ?? this.addressId,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Enum cho loại xe của shipper
enum VehicleType {
  bike,
  motorbike,
  car;

  static VehicleType fromString(String? type) {
    switch (type) {
      case 'bike':
        return VehicleType.bike;
      case 'car':
        return VehicleType.car;
      default:
        return VehicleType.motorbike;
    }
  }

  String get value {
    switch (this) {
      case VehicleType.bike:
        return 'bike';
      case VehicleType.car:
        return 'car';
      default:
        return 'motorbike';
    }
  }

  String get displayName {
    switch (this) {
      case VehicleType.bike:
        return 'Xe đạp';
      case VehicleType.motorbike:
        return 'Xe máy';
      case VehicleType.car:
        return 'Ô tô';
    }
  }
}

/// Model cho bảng shipper_profiles (thông tin riêng cho shipper)
class ShipperProfileModel {
  final String shipperProfileId;
  final String userId;
  final VehicleType? vehicleType;
  final String? vehiclePlate;
  final String? licenseNumber;
  final bool isAvailable;
  final double? currentLatitude;
  final double? currentLongitude;
  final double rating;
  final int totalDeliveries;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShipperProfileModel({
    required this.shipperProfileId,
    required this.userId,
    this.vehicleType,
    this.vehiclePlate,
    this.licenseNumber,
    this.isAvailable = false,
    this.currentLatitude,
    this.currentLongitude,
    this.rating = 5.0,
    this.totalDeliveries = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShipperProfileModel.fromMap(Map<String, dynamic> data) {
    return ShipperProfileModel(
      shipperProfileId: data['shipper_profile_id'] ?? '',
      userId: data['user_id'] ?? '',
      vehicleType: data['vehicle_type'] != null
          ? VehicleType.fromString(data['vehicle_type'])
          : null,
      vehiclePlate: data['vehicle_plate'],
      licenseNumber: data['license_number'],
      isAvailable: data['is_available'] ?? false,
      currentLatitude: data['current_latitude']?.toDouble(),
      currentLongitude: data['current_longitude']?.toDouble(),
      rating: (data['rating'] ?? 5.0).toDouble(),
      totalDeliveries: data['total_deliveries'] ?? 0,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shipper_profile_id': shipperProfileId,
      'user_id': userId,
      'vehicle_type': vehicleType?.value,
      'vehicle_plate': vehiclePlate,
      'license_number': licenseNumber,
      'is_available': isAvailable,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Dùng khi insert mới (không cần shipper_profile_id)
  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'vehicle_type': vehicleType?.value,
      'vehicle_plate': vehiclePlate,
      'license_number': licenseNumber,
      'is_available': isAvailable,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
    };
  }

  ShipperProfileModel copyWith({
    String? shipperProfileId,
    String? userId,
    VehicleType? vehicleType,
    String? vehiclePlate,
    String? licenseNumber,
    bool? isAvailable,
    double? currentLatitude,
    double? currentLongitude,
    double? rating,
    int? totalDeliveries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShipperProfileModel(
      shipperProfileId: shipperProfileId ?? this.shipperProfileId,
      userId: userId ?? this.userId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model tổng hợp user với đầy đủ thông tin (dùng khi cần join nhiều bảng)
class FullUserModel {
  final UserModel user;
  final UserProfileModel? profile;
  final List<UserAddressModel> addresses;
  final ShipperProfileModel? shipperProfile;

  FullUserModel({
    required this.user,
    this.profile,
    this.addresses = const [],
    this.shipperProfile,
  });

  String get userId => user.userId;
  String get email => user.email;
  UserRole get role => user.role;
  String? get fullName => profile?.fullName;
  String? get phone => profile?.phone;
  String? get avatarUrl => profile?.avatarUrl;

  /// Lấy địa chỉ mặc định
  UserAddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((addr) => addr.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  FullUserModel copyWith({
    UserModel? user,
    UserProfileModel? profile,
    List<UserAddressModel>? addresses,
    ShipperProfileModel? shipperProfile,
  }) {
    return FullUserModel(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      addresses: addresses ?? this.addresses,
      shipperProfile: shipperProfile ?? this.shipperProfile,
    );
  }
}
