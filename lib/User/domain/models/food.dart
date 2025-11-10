class Food {
  final String id;
  final String name;
  final double price;
  final String assetSrc;
  final String foodCategory;
  final String restaurantName;

  const Food({
    required this.id,
    required this.name,
    required this.price,
    required this.assetSrc,
    required this.foodCategory,
    required this.restaurantName,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'assetSrc': assetSrc,
      'foodCategory': foodCategory,
      'restaurantName': restaurantName,
    };
  }

  // Create from Map (Firebase data)
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      assetSrc: map['assetSrc'] ?? '',
      foodCategory: map['foodCategory'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
    );
  }
}
