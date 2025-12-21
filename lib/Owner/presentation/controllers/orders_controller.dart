import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/models/order_model.dart';

// Cancel reasons for restaurant
enum CancelReason { closingTime, outOfStock, other }

extension CancelReasonExtension on CancelReason {
  String get displayName {
    switch (this) {
      case CancelReason.closingTime:
        return 'Đến giờ đóng cửa';
      case CancelReason.outOfStock:
        return 'Hết món';
      case CancelReason.other:
        return 'Lý do khác';
    }
  }
}

class OrdersController extends GetxController {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _supabase = SupabaseService();

  final Rx<RestaurantModel?> _restaurant = Rx<RestaurantModel?>(null);
  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString(null);

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  // Load orders của restaurant
  Future<void> loadOrders() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) {
        _error.value = 'User not authenticated';
        return;
      }

      // Lấy restaurant của owner
      _restaurant.value = await _restaurantRepository.getRestaurantByOwnerId(
        userId,
      );

      if (_restaurant.value == null) {
        _error.value = 'Restaurant not found';
        return;
      }

      // Lấy tất cả orders của restaurant
      _orders.assignAll(
        await _orderRepository.getRestaurantOrders(_restaurant.value!.id),
      );
    } catch (e) {
      _error.value = 'Error loading orders: $e';
      print(_error.value);
    } finally {
      _isLoading.value = false;
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

    // Order flow for restaurant:
    // pending -> confirmed (restaurant confirms after shipper accepts or when shipper arrives)
    // confirmed -> preparing (restaurant starts cooking)
    // preparing -> ready_for_pickup (food is ready)
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
        }
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  /// Cancel order with reason - only allowed if shipper hasn't confirmed
  Future<bool> cancelOrderWithReason(
    String orderId,
    CancelReason reason,
  ) async {
    final order = _orders.firstWhereOrNull((o) => o.id == orderId);
    if (order == null) return false;

    // Check if shipper has already confirmed (picked up)
    // If shipper is assigned and order is not pending, cannot cancel
    if (order.shipperId != null && order.status != OrderStatus.pending) {
      _error.value = 'Tài xế đã nhận đơn, không thể hủy';
      return false;
    }

    try {
      final success = await _orderRepository.cancelOrder(orderId);

      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index >= 0) {
          _orders[index] = _orders[index].copyWith(
            status: OrderStatus.cancelled,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await cancelOrderWithReason(orderId, CancelReason.other);
  }

  Future<void> refresh() async {
    await loadOrders();
  }
}
