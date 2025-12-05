import 'package:flutter/material.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/models/order_model.dart';

class DashboardController extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _supabase = SupabaseService();

  RestaurantModel? _restaurant;
  List<OrderModel> _recentOrders = [];

  // Stats
  int ordersToday = 0;
  int ordersThisWeek = 0;
  int ordersThisMonth = 0;

  double revenueToday = 0;
  double revenueThisWeek = 0;
  double revenueThisMonth = 0;

  // Toggle limit
  int toggleCountToday = 0;
  DateTime lastToggleDate = DateTime.now();

  bool _isLoading = false;
  String? _error;

  RestaurantModel? get restaurant => _restaurant;
  List<OrderModel> get recentOrders => _recentOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isOpen => _restaurant?.status == 'open';

  // Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) {
        _error = "User not authenticated";
        return;
      }

      // Get restaurant info
      _restaurant = await _restaurantRepository.getRestaurantByOwnerId(userId);

      if (_restaurant == null) {
        _error = "Restaurant not found";
        return;
      }

      final orders = await _orderRepository.getRestaurantOrders(
        _restaurant!.id,
      );

      _recentOrders = orders.take(5).toList();

      _calculateStats(orders);
    } catch (e) {
      _error = "Dashboard error: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate daily/weekly/monthly stats
  void _calculateStats(List<OrderModel> orders) {
    final now = DateTime.now();

    ordersToday = 0;
    ordersThisWeek = 0;
    ordersThisMonth = 0;

    revenueToday = 0;
    revenueThisWeek = 0;
    revenueThisMonth = 0;

    for (var order in orders) {
      if (order.status != "completed") continue;
      final date = order.createdAt;

      // Today
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        ordersToday++;
        revenueToday += order.totalAmount;
      }

      // Last 7 days
      if (date.isAfter(now.subtract(const Duration(days: 7)))) {
        ordersThisWeek++;
        revenueThisWeek += order.totalAmount;
      }

      // Month
      if (date.year == now.year && date.month == now.month) {
        ordersThisMonth++;
        revenueThisMonth += order.totalAmount;
      }
    }
  }

  // Toggle open/close with limit + confirmation
  Future<bool> toggleOpenConfirm() async {
    final now = DateTime.now();

    // Reset limit if day changes
    if (now.day != lastToggleDate.day) {
      toggleCountToday = 0;
    }

    if (toggleCountToday >= 5) return false;

    final newStatus = isOpen ? "closed" : "open";

    try {
      final success = await _restaurantRepository.updateRestaurantStatus(
        _restaurant!.id,
        newStatus,
      );

      if (success) {
        toggleCountToday++;
        lastToggleDate = now;
        _restaurant = _restaurant!.copyWith(status: newStatus);
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint("Error toggle: $e");
      return false;
    }
  }

  Future<void> refresh() async => loadDashboardData();
}
