import 'dart:async';
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

  // Real-time subscription
  StreamSubscription? _ordersSubscription;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  // Get pending orders count
  int get pendingOrdersCount =>
      _orders.where((o) => o.status == OrderStatus.pending).length;

  // Get new orders (pending)
  List<OrderModel> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }

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

      // Start real-time listener for new orders
      _startListeningForOrders();
    } catch (e) {
      _error.value = 'Error loading orders: $e';
      print(_error.value);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Start listening for new orders in real-time
  void _startListeningForOrders() {
    if (_restaurant.value == null) return;

    _ordersSubscription?.cancel();

    _ordersSubscription = _orderRepository
        .restaurantOrdersStream(_restaurant.value!.id)
        .listen((newOrders) {
          // Update orders list
          _orders.assignAll(newOrders);

          // Show notification for new pending orders
          final previousPendingIds = _orders
              .where((o) => o.status == OrderStatus.pending)
              .map((o) => o.id)
              .toSet();

          final newPendingOrders = newOrders
              .where(
                (o) =>
                    o.status == OrderStatus.pending &&
                    !previousPendingIds.contains(o.id),
              )
              .toList();

          if (newPendingOrders.isNotEmpty) {
            // Show notification for new pending orders
            for (final order in newPendingOrders) {
              _showNewOrderNotification(order);
            }
          }
        });
  }

  /// Show notification for new order
  void _showNewOrderNotification(OrderModel order) {
    Get.snackbar(
      'Đơn hàng mới!',
      'Bạn có đơn hàng mới - ${order.items.length} món - ${order.totalAmount.toStringAsFixed(0)} VND',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.notifications_active, color: Colors.white),
    );
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

  /// Update order status through the flow
  /// Order flow:
  /// - pending -> confirmed (if shipper accepts OR owner confirms)
  /// - confirmed -> preparing (restaurant starts cooking)
  /// - preparing -> ready_for_pickup (food is ready)
  Future<void> updateStatus(String orderId, OrderStatus currentStatus) async {
    OrderStatus? newStatus;

    switch (currentStatus) {
      case OrderStatus.pending:
        // Owner can confirm pending order (shipper may also accept)
        newStatus = OrderStatus.confirmed;
        break;
      case OrderStatus.confirmed:
        // Can only start preparing if shipper is assigned
        final order = _orders.firstWhereOrNull((o) => o.id == orderId);
        if (order != null && order.shipperId == null) {
          _error.value = 'Chưa có shipper nhận đơn, không thể bắt đầu chuẩn bị';
          Get.snackbar(
            'Lỗi',
            'Chưa có shipper nhận đơn, vui lòng chờ',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
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

        Get.snackbar(
          'Thành công',
          'Đã cập nhật trạng thái đơn hàng',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _error.value = 'Lỗi cập nhật trạng thái: $e';
      print('Error updating order status: $e');
    }
  }

  /// Cancel order with reason - only allowed if shipper hasn't picked up
  Future<bool> cancelOrderWithReason(
    String orderId,
    CancelReason reason,
  ) async {
    final order = _orders.firstWhereOrNull((o) => o.id == orderId);
    if (order == null) {
      _error.value = 'Đơn hàng không tồn tại';
      return false;
    }

    // Can only cancel if order is pending or confirmed (before shipper picks up)
    // Cannot cancel if shipper has already picked up (status is delivering or delivered)
    if (order.status == OrderStatus.delivering ||
        order.status == OrderStatus.delivered ||
        order.status == OrderStatus.readyForPickup) {
      _error.value = 'Không thể hủy đơn hàng đã được shipper lấy';
      Get.snackbar(
        'Lỗi',
        'Không thể hủy đơn hàng đã được shipper lấy',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      final success = await _orderRepository.updateOrder(orderId, {
        'status': 'cancelled',
        'cancel_reason': reason.displayName,
      });

      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index >= 0) {
          _orders[index] = _orders[index].copyWith(
            status: OrderStatus.cancelled,
            cancelReason: reason.displayName,
          );
        }

        Get.snackbar(
          'Thành công',
          'Đã hủy đơn hàng',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        return true;
      }
      return false;
    } catch (e) {
      _error.value = 'Lỗi hủy đơn hàng: $e';
      print('Error cancelling order: $e');
      return false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await cancelOrderWithReason(orderId, CancelReason.other);
  }

  /// Confirm order - restaurant accepts the order
  /// This should be called when owner confirms a pending order
  /// After confirmation, order becomes 'confirmed' and shippers can see it
  Future<bool> confirmOrder(String orderId) async {
    final order = _orders.firstWhereOrNull((o) => o.id == orderId);
    if (order == null) {
      _error.value = 'Đơn hàng không tồn tại';
      return false;
    }

    // Only allow confirming pending orders
    if (order.status != OrderStatus.pending) {
      _error.value = 'Chỉ có thể xác nhận đơn hàng đang chờ';
      return false;
    }

    try {
      final success = await _orderRepository.updateOrder(orderId, {
        'status': 'confirmed',
      });

      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index >= 0) {
          _orders[index] = _orders[index].copyWith(
            status: OrderStatus.confirmed,
          );
        }

        Get.snackbar(
          'Thành công',
          'Đã xác nhận đơn hàng',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        print('Restaurant confirmed order: $orderId');
        return true;
      }
      return false;
    } catch (e) {
      _error.value = 'Lỗi xác nhận đơn hàng: $e';
      print('Error confirming order: $e');
      return false;
    }
  }

  Future<void> refresh() async {
    await loadOrders();
  }
}
