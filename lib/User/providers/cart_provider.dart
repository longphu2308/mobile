import 'package:flutter/foundation.dart';
import 'package:mobile/User/models/cart_item.dart';
import 'package:mobile/User/models/food.dart';
import 'package:mobile/User/providers/order_provider.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  OrderProvider? _orderProvider;

  void setOrderProvider(OrderProvider orderProvider) {
    _orderProvider = orderProvider;
  }

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Group items by restaurant
  Map<String, List<CartItem>> get itemsByRestaurant {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in _items) {
      final restaurantName = item.food.restaurantName;
      if (!grouped.containsKey(restaurantName)) {
        grouped[restaurantName] = [];
      }
      grouped[restaurantName]!.add(item);
    }
    return grouped;
  }

  void addItem(Food food) {
    final existingIndex = _items.indexWhere((item) => item.food.name == food.name && item.food.restaurantName == food.restaurantName);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(food: food));
    }
    notifyListeners();
  }

  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  void updateQuantity(CartItem cartItem, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItem);
    } else {
      cartItem.quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Place order and add to history
  void placeOrder() {
    if (_items.isNotEmpty && _orderProvider != null) {
      _orderProvider!.addOrder(
        List.from(_items),
        totalPrice,
        itemsByRestaurant,
      );
      _items.clear();
      notifyListeners();
    }
  }

  // Check if cart can place order (has items)
  bool get canPlaceOrder => _items.isNotEmpty;
}

