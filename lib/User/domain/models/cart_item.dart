import 'package:mobile/User/domain/models/food.dart';

class CartItem {
  final Food food;
  int quantity;

  CartItem({
    required this.food,
    this.quantity = 1,
  });

  double get totalPrice => food.price * quantity;

  CartItem copyWith({
    Food? food,
    int? quantity,
  }) {
    return CartItem(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }
}

