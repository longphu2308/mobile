import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/models/order_model.dart';

class OrdersController extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final OrderRepository _orderRepository = OrderRepository();

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
      final userId = FirebaseAuth.instance.currentUser?.uid;
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

  Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'delivered':
        return 'Hoàn tất';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Future<void> updateStatus(String orderId, String currentStatus) async {
    String? newStatus;

    switch (currentStatus) {
      case 'pending':
        newStatus = 'preparing';
        break;
      case 'preparing':
        newStatus = 'delivered';
        break;
      default:
        return;
    }

    try {
      final success = await _orderRepository.updateOrderStatus(
        orderId,
        newStatus,
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
          _orders[index] = _orders[index].copyWith(status: 'cancelled');
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
