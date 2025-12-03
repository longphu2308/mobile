import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/models/order_model.dart';

class DashboardController extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final OrderRepository _orderRepository = OrderRepository();

  RestaurantModel? _restaurant;
  List<OrderModel> _recentOrders = [];
  Map<String, int> _orderStats = {};
  double _revenue = 0.0;
  bool _isLoading = false;
  String? _error;

  RestaurantModel? get restaurant => _restaurant;
  List<OrderModel> get recentOrders => _recentOrders;
  Map<String, int> get orderStats => _orderStats;
  double get revenue => _revenue;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOpen => _restaurant?.status == 'open';

  // Load dữ liệu dashboard
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _error = 'User not authenticated';
        return;
      }

      // Lấy thông tin restaurant của owner
      _restaurant = await _restaurantRepository.getRestaurantByOwnerId(userId);

      if (_restaurant == null) {
        _error = 'Restaurant not found';
        return;
      }

      // Lấy orders gần đây
      final allOrders = await _orderRepository.getRestaurantOrders(
        _restaurant!.id,
      );
      _recentOrders = allOrders.take(5).toList();

      // Tính thống kê orders
      _orderStats = await _orderRepository.countOrdersByStatus(_restaurant!.id);

      // Tính doanh thu
      _revenue = await _orderRepository.calculateRestaurantRevenue(
        _restaurant!.id,
      );
    } catch (e) {
      _error = 'Error loading dashboard: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle trạng thái quán (open/closed)
  Future<void> toggleOpen() async {
    if (_restaurant == null) return;

    final newStatus = _restaurant!.status == 'open' ? 'closed' : 'open';

    try {
      final success = await _restaurantRepository.updateRestaurantStatus(
        _restaurant!.id,
        newStatus,
      );

      if (success) {
        _restaurant = _restaurant!.copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling restaurant status: $e');
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadDashboardData();
  }
}
