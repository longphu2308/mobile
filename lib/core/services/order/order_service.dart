import 'package:flutter/foundation.dart';
import 'package:mobile/User/domain/models/order.dart';
import 'package:mobile/User/domain/models/cart_item.dart';

class OrderService extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders.reversed);

  void addOrder(List<CartItem> items, double totalPrice) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items.map((item) => CartItem(
        food: item.food,
        quantity: item.quantity,
      )).toList(),
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
      status: 'completed',
    );
    
    _orders.add(order);
    notifyListeners();
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }
}

