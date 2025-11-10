import 'package:flutter/foundation.dart';
import 'package:mobile/User/domain/models/cart_item.dart';
import 'package:mobile/User/domain/models/food.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Food food) {
    final existingIndex = _items.indexWhere((item) => item.food.name == food.name);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(food: food, quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String foodName) {
    _items.removeWhere((item) => item.food.name == foodName);
    notifyListeners();
  }

  void updateQuantity(String foodName, int quantity) {
    if (quantity <= 0) {
      removeItem(foodName);
      return;
    }
    
    final index = _items.indexWhere((item) => item.food.name == foodName);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void incrementQuantity(String foodName) {
    final index = _items.indexWhere((item) => item.food.name == foodName);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String foodName) {
    final index = _items.indexWhere((item) => item.food.name == foodName);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        removeItem(foodName);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

