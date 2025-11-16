import 'package:mobile/User/models/cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderTime;
  final Map<String, List<CartItem>> itemsByRestaurant;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.orderTime,
    required this.itemsByRestaurant,
  });

  String get formattedTime {
    final hour = orderTime.hour.toString().padLeft(2, '0');
    final minute = orderTime.minute.toString().padLeft(2, '0');
    final day = orderTime.day.toString().padLeft(2, '0');
    final month = orderTime.month.toString().padLeft(2, '0');
    final year = orderTime.year;
    return '$hour:$minute - $day/$month/$year';
  }
}

