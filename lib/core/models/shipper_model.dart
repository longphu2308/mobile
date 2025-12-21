class ShipperProfileModel {
  final String shipperProfileId;
  final String userId;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? licenseNumber;
  final bool isAvailable;
  final double? currentLatitude;
  final double? currentLongitude;
  final double rating;
  final int totalDeliveries;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;

  ShipperProfileModel({
    required this.shipperProfileId,
    required this.userId,
    this.vehicleType,
    this.vehiclePlate,
    this.licenseNumber,
    required this.isAvailable,
    this.currentLatitude,
    this.currentLongitude,
    required this.rating,
    required this.totalDeliveries,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
  });

  // Chuyển từ Supabase data sang model
  factory ShipperProfileModel.fromMap(Map<String, dynamic> data) {
    return ShipperProfileModel(
      shipperProfileId: data['shipper_profile_id'] ?? '',
      userId: data['user_id'] ?? '',
      vehicleType: data['vehicle_type'],
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
      lastSeen: data['last_seen'] != null
          ? DateTime.parse(data['last_seen'])
          : null,
    );
  }

  // Chuyển sang Map để gửi lên Supabase
  Map<String, dynamic> toMap() {
    return {
      'shipper_profile_id': shipperProfileId,
      'user_id': userId,
      'vehicle_type': vehicleType,
      'vehicle_plate': vehiclePlate,
      'license_number': licenseNumber,
      'is_available': isAvailable,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  // Copy with
  ShipperProfileModel copyWith({
    String? shipperProfileId,
    String? userId,
    String? vehicleType,
    String? vehiclePlate,
    String? licenseNumber,
    bool? isAvailable,
    double? currentLatitude,
    double? currentLongitude,
    double? rating,
    int? totalDeliveries,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
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
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}