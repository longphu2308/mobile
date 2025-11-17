class Food {
  final String name;
  final double price;
  final String assetSrc;
  final String foodCategory;
  final String vendorId;
  final String vendorName;

  const Food({
    required this.name,
    required this.price,
    required this.assetSrc,
    required this.foodCategory,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Food && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  static final List<Food> foodList = [
    Food(
      name: 'Veggie tomato mix',
      price: 19000,
      assetSrc: 'assets/images/tomatomix.png',
      foodCategory: 'Foods',
      vendorId: 'vendor_1',
      vendorName: 'Veggie Delight',
    ),
    Food(
      name: 'Spicy fish sauce',
      price: 23500,
      assetSrc: 'assets/images/food1.png',
      foodCategory: 'Foods',
      vendorId: 'vendor_1',
      vendorName: 'Veggie Delight',
    ),
    Food(
      name: 'Egg and cucumber',
      price: 19000,
      assetSrc: 'assets/images/food2.png',
      foodCategory: 'Foods',
      vendorId: 'vendor_2',
      vendorName: 'Fresh Farm',
    ),
    Food(
      name: 'Fried chicken',
      price: 19000,
      assetSrc: 'assets/images/food 5.png',
      foodCategory: 'Foods',
      vendorId: 'vendor_2',
      vendorName: 'Fresh Farm',
    ),
    Food(
      name: 'Moi-moi and ekpa',
      price: 19000,
      assetSrc: 'assets/images/food 6.png',
      foodCategory: 'Foods',
      vendorId: 'vendor_3',
      vendorName: 'Saigon Kitchen',
    ),
    Food(
      name: 'Spicy chicken',
      price: 19000,
      assetSrc: 'assets/images/food 7.png',
      foodCategory: 'Foods',
      vendorId: 'vendor_3',
      vendorName: 'Saigon Kitchen',
    ),
  ];
}

