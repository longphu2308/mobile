class Food {
  final String name;
  final double price;
  final String assetSrc;
  final String foodCategory;
  final String restaurantName;

  const Food({
    required this.name,
    required this.price,
    required this.assetSrc,
    required this.foodCategory,
    required this.restaurantName,
  });

  static final List<Food> foodList = [
    Food(
      name: 'Veggie tomato mix',
      price: 19000,
      assetSrc: 'assets/images/tomatomix.png',
      foodCategory: 'Foods',
      restaurantName: 'Nhà hàng ABC',
    ),
    Food(
      name: 'Spicy fish sauce',
      price: 23500,
      assetSrc: 'assets/images/food1.png',
      foodCategory: 'Foods',
      restaurantName: 'Nhà hàng ABC',
    ),
    Food(
      name: 'Egg and cucumber',
      price: 19000,
      assetSrc: 'assets/images/food2.png',
      foodCategory: 'Foods',
      restaurantName: 'Nhà hàng XYZ',
    ),
    Food(
      name: 'Fried chicken',
      price: 19000,
      assetSrc: 'assets/images/food 5.png',
      foodCategory: 'Foods',
      restaurantName: 'Nhà hàng XYZ',
    ),
    Food(
      name: 'Moi-moi and ekpa',
      price: 19000,
      assetSrc: 'assets/images/food 6.png',
      foodCategory: 'Foods',
      restaurantName: 'Nhà hàng 123',
    ),
    Food(
      name: 'Spicy chicken',
      price: 19000,
      assetSrc: 'assets/images/food 7.png',
      foodCategory: 'Foods',
      restaurantName: 'Nhà hàng 123',
    ),
  ];
}

