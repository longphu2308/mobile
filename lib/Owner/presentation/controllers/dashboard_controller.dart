import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/models/order_model.dart';

class DashboardController extends GetxController {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _supabase = SupabaseService();

  final Rx<RestaurantModel?> _restaurant = Rx<RestaurantModel?>(null);
  final RxList<OrderModel> _recentOrders = <OrderModel>[].obs;

  // Stats
  final RxInt ordersToday = 0.obs;
  final RxInt ordersThisWeek = 0.obs;
  final RxInt ordersThisMonth = 0.obs;

  final RxDouble revenueToday = 0.0.obs;
  final RxDouble revenueThisWeek = 0.0.obs;
  final RxDouble revenueThisMonth = 0.0.obs;

  // Toggle limit
  final RxInt toggleCountToday = 0.obs;
  DateTime lastToggleDate = DateTime.now();

  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString(null);

  RestaurantModel? get restaurant => _restaurant.value;
  List<OrderModel> get recentOrders => _recentOrders;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  bool get isOpen => _restaurant.value?.status == 'open';

  // Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) {
        _error.value = "User not authenticated";
        debugPrint("Dashboard: User not authenticated");
        return;
      }

      debugPrint("Dashboard: Loading data for user: $userId");

      // Get restaurant info
      _restaurant.value = await _restaurantRepository.getRestaurantByOwnerId(
        userId,
      );

      if (_restaurant.value == null) {
        _error.value = "Restaurant not found";
        debugPrint("Dashboard: Restaurant not found for user: $userId");
        return;
      }

      debugPrint("Dashboard: Found restaurant: ${_restaurant.value!.name} (${_restaurant.value!.id})");

      final orders = await _orderRepository.getRestaurantOrders(
        _restaurant.value!.id,
      );

      debugPrint("Dashboard: Loaded ${orders.length} orders");

      _recentOrders.assignAll(orders.take(5).toList());

      _calculateStats(orders);
    } catch (e) {
      _error.value = "Dashboard error: $e";
      debugPrint(_error.value);
    } finally {
      _isLoading.value = false;
    }
  }

  // Calculate daily/weekly/monthly stats
  void _calculateStats(List<OrderModel> orders) {
    final now = DateTime.now();

    ordersToday.value = 0;
    ordersThisWeek.value = 0;
    ordersThisMonth.value = 0;

    revenueToday.value = 0;
    revenueThisWeek.value = 0;
    revenueThisMonth.value = 0;

    for (var order in orders) {
      if (order.status != OrderStatus.delivered) continue;
      final date = order.createdAt;

      // Today
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        ordersToday.value++;
        revenueToday.value += order.totalAmount;
      }

      // Last 7 days
      if (date.isAfter(now.subtract(const Duration(days: 7)))) {
        ordersThisWeek.value++;
        revenueThisWeek.value += order.totalAmount;
      }

      // Month
      if (date.year == now.year && date.month == now.month) {
        ordersThisMonth.value++;
        revenueThisMonth.value += order.totalAmount;
      }
    }
  }

  // Toggle open/close with limit + confirmation
  Future<bool> toggleOpenConfirm() async {
    final now = DateTime.now();

    // Reset limit if day changes
    if (now.day != lastToggleDate.day) {
      toggleCountToday.value = 0;
    }

    if (toggleCountToday.value >= 5) return false;

    final newStatus = isOpen ? "closed" : "open";

    try {
      final success = await _restaurantRepository.updateRestaurantStatus(
        _restaurant.value!.id,
        newStatus,
      );

      if (success) {
        toggleCountToday.value++;
        lastToggleDate = now;
        _restaurant.value = _restaurant.value!.copyWith(status: newStatus);
      }

      return success;
    } catch (e) {
      debugPrint("Error toggle: $e");
      return false;
    }
  }

  Future<void> refresh() async => loadDashboardData();
}
