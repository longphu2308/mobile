import 'package:flutter/material.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/models/order_model.dart';

class OrdersController extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _supabase = SupabaseService();

  RestaurantModel? _restaurant;
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load orders của restaurant
  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) {
        _error = 'User not authenticated';
        return;
      }

      // Lấy restaurant của owner
      _restaurant = await _restaurantRepository.getRestaurantByOwnerId(userId);

      if (_restaurant == null) {
        _error = 'Restaurant not found';
        return;
      }

      // Lấy tất cả orders của restaurant
      _orders = await _orderRepository.getRestaurantOrders(_restaurant!.id);
    } catch (e) {
      _error = 'Error loading orders: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Color statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.readyForPickup:
        return Colors.teal;
      case OrderStatus.delivering:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String statusText(OrderStatus status) {
    return status.displayName;
  }

  Future<void> updateStatus(String orderId, OrderStatus currentStatus) async {
    OrderStatus? newStatus;

    switch (currentStatus) {
      case OrderStatus.pending:
        newStatus = OrderStatus.confirmed;
        break;
      case OrderStatus.confirmed:
        newStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        newStatus = OrderStatus.readyForPickup;
        break;
      case OrderStatus.readyForPickup:
        newStatus = OrderStatus.delivering;
        break;
      case OrderStatus.delivering:
        newStatus = OrderStatus.delivered;
        break;
      default:
        return;
    }

    try {
      final success = await _orderRepository.updateOrderStatus(
        orderId,
        newStatus.value,
      );

      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index >= 0) {
          _orders[index] = _orders[index].copyWith(status: newStatus);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final success = await _orderRepository.cancelOrder(orderId);

      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index >= 0) {
          _orders[index] = _orders[index].copyWith(
            status: OrderStatus.cancelled,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error cancelling order: $e');
    }
  }

  Future<void> refresh() async {
    await loadOrders();
  }
}
