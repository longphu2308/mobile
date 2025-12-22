import 'dart:async';
import 'package:get/get.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/Shipper/services/shipper_notification_service.dart';

/// Order status flow for shipper:
/// - pending: User created order, finding available driver
/// - confirmed: Restaurant accepted, driver accepted -> preparing
/// - preparing: Restaurant is cooking
/// - ready_for_pickup: Food is ready, driver should go pick up
/// - delivering: Driver picked up, on the way to customer
/// - delivered: Order completed
/// - cancelled: Order cancelled

class ShipperController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();
  final _supabase = SupabaseService();

  // Current shipper's assigned orders
  final RxList<OrderModel> _assignedOrders = <OrderModel>[].obs;

  // Available orders nearby for acceptance
  final RxList<OrderModel> _availableOrders = <OrderModel>[].obs;

  // Order history
  final RxList<OrderModel> _completedOrders = <OrderModel>[].obs;

  final RxBool _isLoading = false.obs;
  final RxBool _isOnline = false.obs;
  final RxnString _error = RxnString(null);

  // Current active order being delivered
  final Rx<OrderModel?> _currentOrder = Rx<OrderModel?>(null);

  // Stats
  final RxInt _todayOrderCount = 0.obs;
  final RxDouble _todayEarnings = 0.0.obs;

  // Stream subscription for real-time updates
  StreamSubscription? _ordersSubscription;

  // Getters
  List<OrderModel> get assignedOrders => _assignedOrders;
  List<OrderModel> get availableOrders => _availableOrders;
  List<OrderModel> get completedOrders => _completedOrders;
  bool get isLoading => _isLoading.value;
  bool get isOnline => _isOnline.value;
  String? get error => _error.value;
  OrderModel? get currentOrder => _currentOrder.value;
  int get todayOrderCount => _todayOrderCount.value;
  double get todayEarnings => _todayEarnings.value;

  String? get shipperId => _supabase.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    loadAssignedOrders();
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }

  /// Toggle online/offline status
  void toggleOnlineStatus() {
    _isOnline.value = !_isOnline.value;
    if (_isOnline.value) {
      _startListeningForOrders();
      loadAvailableOrders();
    } else {
      _ordersSubscription?.cancel();
      _availableOrders.clear();
    }
  }

  /// Start listening for new available orders (real-time)
  /// Listen for orders with status 'pending' (user just created) that need a driver
  void _startListeningForOrders() {
    _ordersSubscription?.cancel();

    // Listen for orders with status 'pending' (user just created) that need a driver
    _ordersSubscription = _supabase.client
        .from('orders')
        .stream(primaryKey: ['order_id'])
        .eq('status', 'pending')
        .listen((data) {
          final orders = data
              .map((e) => OrderModel.fromMap(e, e['order_id']))
              .toList();
          // Filter orders without a shipper assigned
          final newAvailableOrders = orders
              .where((o) => o.shipperId == null)
              .toList();

          // Check for new orders that weren't in the list before
          final previousOrderIds = _availableOrders.map((o) => o.id).toSet();
          final newOrders = newAvailableOrders
              .where((o) => !previousOrderIds.contains(o.id))
              .toList();

          // Show notification for new orders
          for (final order in newOrders) {
            ShipperNotificationService().showNewOrderNotification(order);
          }

          _availableOrders.assignAll(newAvailableOrders);
        });
  }

  /// Load orders assigned to this shipper
  Future<void> loadAssignedOrders() async {
    if (shipperId == null) return;

    _isLoading.value = true;
    _error.value = null;

    try {
      final orders = await _orderRepository.getOrdersByShipper(shipperId!);

      // Separate by status
      _assignedOrders.assignAll(
        orders.where(
          (o) => ![
            OrderStatus.delivered,
            OrderStatus.cancelled,
          ].contains(o.status),
        ),
      );

      _completedOrders.assignAll(
        orders.where((o) => o.status == OrderStatus.delivered),
      );

      // Set current active order
      final activeOrders = orders
          .where(
            (o) => [
              OrderStatus.confirmed,
              OrderStatus.preparing,
              OrderStatus.readyForPickup,
              OrderStatus.delivering,
            ].contains(o.status),
          )
          .toList();

      if (activeOrders.isNotEmpty) {
        _currentOrder.value = activeOrders.first;
      }

      // Calculate today's stats
      _calculateTodayStats(orders);
    } catch (e) {
      _error.value = 'Error loading assigned orders: $e';
      print(_error.value);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load available orders for acceptance
  /// Get pending orders (user just created) without shipper
  Future<void> loadAvailableOrders() async {
    if (!_isOnline.value) return;

    try {
      // Get pending orders (user just created) without shipper
      final allPending = await _orderRepository.getOrdersByStatus('pending');
      _availableOrders.assignAll(
        allPending.where((o) => o.shipperId == null).toList(),
      );
    } catch (e) {
      print('Error loading available orders: $e');
    }
  }

  /// Accept an order - shipper claims this order
  /// Order is 'pending' (user just created)
  /// After shipper accepts, order becomes 'confirmed' (shipper assigned, waiting for restaurant)
  Future<bool> acceptOrder(String orderId) async {
    if (shipperId == null) return false;

    try {
      // Check if order is still available (not taken by another shipper)
      final order = await _orderRepository.getOrderById(orderId);
      if (order == null) {
        _error.value = 'Đơn hàng không tồn tại';
        return false;
      }

      // Can accept pending orders
      if (order.status != OrderStatus.pending) {
        _error.value = 'Đơn hàng không ở trạng thái có thể nhận';
        return false;
      }

      if (order.shipperId != null) {
        _error.value = 'Đơn hàng đã được shipper khác nhận';
        return false;
      }

      // Update order with shipper info and change status to 'confirmed'
      final success = await _orderRepository.updateOrder(orderId, {
        'shipper_id': shipperId,
        'status': 'confirmed', // Shipper accepted -> confirmed
      });

      if (success) {
        // Remove from available, add to assigned
        final availableOrder = _availableOrders.firstWhereOrNull(
          (o) => o.id == orderId,
        );
        if (availableOrder != null) {
          _availableOrders.remove(availableOrder);
          final updatedOrder = availableOrder.copyWith(
            shipperId: shipperId,
            status: OrderStatus.confirmed,
          );
          _assignedOrders.add(updatedOrder);
        }

        await loadAssignedOrders();
        print('Shipper ${shipperId} accepted order ${orderId}');
        return true;
      }
      return false;
    } catch (e) {
      _error.value = 'Lỗi nhận đơn hàng: $e';
      print(_error.value);
      return false;
    }
  }

  /// Decline an order - remove from available list
  void declineOrder(String orderId) {
    _availableOrders.removeWhere((o) => o.id == orderId);
  }

  /// Confirm pickup - change status to 'delivering'
  /// Can only do this when status is 'ready_for_pickup'
  Future<bool> confirmPickup(String orderId) async {
    final order = _assignedOrders.firstWhereOrNull((o) => o.id == orderId);
    if (order == null || order.status != OrderStatus.readyForPickup) {
      _error.value = 'Chưa thể lấy hàng - món ăn chưa sẵn sàng';
      return false;
    }

    try {
      final success = await _orderRepository.updateOrder(orderId, {
        'status': 'delivering',
      });

      if (success) {
        final idx = _assignedOrders.indexWhere((o) => o.id == orderId);
        if (idx >= 0) {
          _assignedOrders[idx] = order.copyWith(status: OrderStatus.delivering);
          _currentOrder.value = _assignedOrders[idx];
        }
        return true;
      }
      return false;
    } catch (e) {
      _error.value = 'Error confirming pickup: $e';
      print(_error.value);
      return false;
    }
  }

  /// Confirm delivery - change status to 'delivered'
  /// Can only do this when status is 'delivering'
  Future<bool> confirmDelivery(String orderId) async {
    final order = _assignedOrders.firstWhereOrNull((o) => o.id == orderId);
    if (order == null || order.status != OrderStatus.delivering) {
      _error.value = 'Không thể hoàn thành - chưa lấy hàng';
      return false;
    }

    try {
      final success = await _orderRepository.updateOrder(orderId, {
        'status': 'delivered',
        'delivered_at': DateTime.now().toIso8601String(),
      });

      if (success) {
        final completedOrder = order.copyWith(
          status: OrderStatus.delivered,
          deliveredAt: DateTime.now(),
        );

        _assignedOrders.removeWhere((o) => o.id == orderId);
        _completedOrders.insert(0, completedOrder);
        _currentOrder.value = null;

        // Update stats
        _todayOrderCount.value++;
        // Add delivery fee to earnings (assuming 15000 VND per order)
        _todayEarnings.value += 15000;

        return true;
      }
      return false;
    } catch (e) {
      _error.value = 'Error confirming delivery: $e';
      print(_error.value);
      return false;
    }
  }

  /// Calculate today's statistics
  void _calculateTodayStats(List<OrderModel> orders) {
    final today = DateTime.now();
    final todayOrders = orders.where((o) {
      if (o.deliveredAt == null) return false;
      return o.deliveredAt!.year == today.year &&
          o.deliveredAt!.month == today.month &&
          o.deliveredAt!.day == today.day &&
          o.status == OrderStatus.delivered;
    }).toList();

    _todayOrderCount.value = todayOrders.length;
    // Assuming 15000 VND delivery fee per order
    _todayEarnings.value = todayOrders.length * 15000.0;
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadAssignedOrders();
    if (_isOnline.value) {
      await loadAvailableOrders();
    }
  }
}
