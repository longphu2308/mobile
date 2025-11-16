import 'package:flutter/foundation.dart';
import 'package:mobile/User/models/order.dart';
import 'package:mobile/User/models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(List<CartItem> items, double totalPrice, Map<String, List<CartItem>> itemsByRestaurant) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(items),
      totalPrice: totalPrice,
      orderTime: DateTime.now(),
      itemsByRestaurant: Map.from(itemsByRestaurant),
    );
    _orders.insert(0, order); // Thêm vào đầu danh sách
    notifyListeners();
  }
}

