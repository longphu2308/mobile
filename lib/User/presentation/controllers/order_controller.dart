import 'package:get/get.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/core/models/cart_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/models/shipper_model.dart';

enum OrderState { initial, loading, success, error }

class OrderController extends GetxController {
  final OrderRepository _orderRepository;
  final AuthController? _authController;
  final SupabaseService _supabase = SupabaseService();

  final RxList<OrderModel> _orders = <OrderModel>[].obs;
  final Rx<OrderModel?> _currentOrder = Rx<OrderModel?>(null);
  final Rx<OrderState> _state = OrderState.initial.obs;
  final RxnString _errorMessage = RxnString(null);
  final RxBool _isLoading = false.obs;
  String? _currentUserId;

  // Getters
  List<OrderModel> get orders => _orders.reversed.toList();
  OrderModel? get currentOrder => _currentOrder.value;
  OrderState get state => _state.value;
  String? get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;

  OrderController({
    OrderRepository? orderRepository,
    AuthController? authController,
  }) : _orderRepository = orderRepository ?? OrderRepository(),
       _authController = authController {
    _init();
  }

  void _init() {
    _authController?.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    final userId = _authController?.currentUser?.userId;
    print('OrderController: Auth state changed - userId: $userId');
    print('OrderController: currentUser: ${_authController?.currentUser}');
    print('OrderController: authController exists: ${_authController != null}');

    if (userId != null && userId != _currentUserId) {
      _currentUserId = userId;
      loadUserOrders();
    } else if (userId == null) {
      _currentUserId = null;
      _orders.clear();
    }
  }

  /// Load user's orders from Supabase
  Future<void> loadUserOrders() async {
    // Try to get userId from multiple sources
    String? userId = _currentUserId ?? 
                     _authController?.currentUser?.userId ?? 
                     _supabase.currentUser?.id;
    
    if (userId == null) {
      print('OrderController: Cannot load orders - no user logged in');
      return;
    }
    
    // Update _currentUserId if it was null
    _currentUserId ??= userId;

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      print('OrderController: Loading orders for user $userId');
      List<OrderModel> orders = await _orderRepository.getUserOrders(userId);
      _orders.assignAll(orders);
      _state.value = OrderState.success;
      print('OrderController: Loaded ${orders.length} orders');
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = OrderState.error;
      print('OrderController: Error loading orders - ${e.message}');
    } catch (e) {
      _errorMessage.value = 'Lỗi tải đơn hàng';
      _state.value = OrderState.error;
      print('OrderController: Error loading orders - $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create a new order
  Future<bool> createOrder(
    List<CartItemModel> items,
    double totalAmount, {
    required String restaurantId,
    required String deliveryAddress,
    String paymentMethod = 'cash',
    String? note,
  }) async {
    // Try to get userId from AuthController first, then fallback to Supabase
    String? userId = _currentUserId ?? _supabase.currentUser?.id;

    print('createOrder called - userId: $userId, items: ${items.length}');

    if (userId == null) {
      _errorMessage.value = 'Lỗi: Bạn chưa đăng nhập';
      print('Error: userId is null');
      return false;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      // Convert CartItemModel to OrderItemModel
      final orderItems = items
          .map(
            (item) => OrderItemModel(
              foodId: item.foodId,
              foodName: item.foodName,
              quantity: item.quantity,
              price: item.price,
            ),
          )
          .toList();

      // Create order model - status pending, waiting for shipper and restaurant
      final order = OrderModel(
        id: '', // Will be set by Supabase
        userId: userId,
        restaurantId: restaurantId,
        items: orderItems,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        note: note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Supabase
      final orderId = await _orderRepository.createOrder(order);

      if (orderId != null) {
        final createdOrder = order.copyWith(id: orderId);
        _orders.add(createdOrder);
        _currentOrder.value = createdOrder;
        _state.value = OrderState.success;
        _isLoading.value = false;
        print('Order created successfully with id: $orderId');

        // Send notifications to shippers and restaurant
        _notifyShippersAndRestaurant(createdOrder);

        return true;
      } else {
        _errorMessage.value = 'Không thể tạo đơn hàng';
        _state.value = OrderState.error;
        _isLoading.value = false;
        return false;
      }
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = OrderState.error;
      _isLoading.value = false;
      print('FirestoreException: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage.value = 'Lỗi: ${e.toString()}';
      _state.value = OrderState.error;
      _isLoading.value = false;
      print('Error creating order: $e');
      return false;
    }
  }

  /// Get order by ID
  Future<bool> getOrderById(String orderId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      OrderModel? order = await _orderRepository.getOrderById(orderId);

      if (order != null) {
        _currentOrder.value = order;
        _state.value = OrderState.success;
      } else {
        _state.value = OrderState.error;
        _errorMessage.value = 'Đơn hàng không tồn tại';
      }
      _isLoading.value = false;
      return order != null;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = OrderState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final success = await _orderRepository.updateOrderStatus(
        orderId,
        status.value,
      );

      if (success) {
        // Update local state
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index >= 0) {
          _orders[index] = _orders[index].copyWith(status: status);
        }

        if (_currentOrder.value?.id == orderId) {
          _currentOrder.value = _currentOrder.value!.copyWith(status: status);
        }

        _state.value = OrderState.success;
      }
      _isLoading.value = false;
      return success;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = OrderState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Cancel order - only allowed if status is pending
  Future<bool> cancelOrder(String orderId) async {
    final order = _orders.firstWhereOrNull((o) => o.id == orderId);
    if (order == null) {
      _errorMessage.value = 'Đơn hàng không tồn tại';
      return false;
    }

    // Only allow cancellation if pending
    if (order.status != OrderStatus.pending) {
      _errorMessage.value = 'Không thể hủy đơn hàng ở trạng thái này';
      return false;
    }

    return await updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  /// Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// Get pending orders
  List<OrderModel> getPendingOrders() {
    return getOrdersByStatus(OrderStatus.pending);
  }

  /// Get completed orders
  List<OrderModel> getCompletedOrders() {
    return getOrdersByStatus(OrderStatus.delivered);
  }

  /// Get cancelled orders
  List<OrderModel> getCancelledOrders() {
    return getOrdersByStatus(OrderStatus.cancelled);
  }

  /// Get order count by status
  int getOrderCountByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).length;
  }

  /// Get total spent
  double getTotalSpent() {
    return _orders
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  /// Get recent orders (last 10)
  List<OrderModel> getRecentOrders({int limit = 10}) {
    return _orders.take(limit).toList();
  }

  /// Send notifications to available shippers and restaurant
  Future<void> _notifyShippersAndRestaurant(OrderModel order) async {
    try {
      // Get available shippers
      final availableShippers = await _orderRepository.getAvailableShippers();

      // Send notification to all available shippers
      for (final shipper in availableShippers) {
        _sendNotificationToShipper(shipper.userId, order);
      }

      // Send notification to restaurant
      _sendNotificationToRestaurant(order.restaurantId, order);

      // Set timeout to cancel order if no shipper accepts within 1 hour
      _scheduleOrderTimeout(order.id);
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  /// Send notification to shipper
  void _sendNotificationToShipper(String shipperId, OrderModel order) {
    // Notification will be sent via real-time listener in ShipperController
    // ShipperNotificationService.showNewOrderNotification() will be called automatically
    print(
      'NOTIFICATION TO SHIPPER ${shipperId}: New order ${order.id} available!',
    );
    print(
      'Order details: ${order.items.length} items, Total: ${order.totalAmount}',
    );
    print('Delivery address: ${order.deliveryAddress}');
  }

  /// Send notification to restaurant
  void _sendNotificationToRestaurant(String restaurantId, OrderModel order) {
    // TODO: Implement push notification to restaurant owner
    // For now, just print notification
    print(
      'NOTIFICATION TO RESTAURANT ${restaurantId}: New order ${order.id} received!',
    );
    print(
      'Order details: ${order.items.length} items, Total: ${order.totalAmount}',
    );
    print('Customer address: ${order.deliveryAddress}');

    // You can add real push notification here later
    // Example: sendPushNotificationToRestaurant(restaurantId, order);
  }

  /// Schedule timeout to cancel order if no shipper accepts within 1 minute
  void _scheduleOrderTimeout(String orderId) {
    Future.delayed(const Duration(minutes: 1), () async {
      try {
        // Check if order is still pending (no shipper accepted)
        final currentOrder = await _orderRepository.getOrderById(orderId);
        if (currentOrder != null &&
            currentOrder.status == OrderStatus.pending &&
            currentOrder.shipperId == null) {
          // Cancel the order but keep it in database
          await _orderRepository.cancelOrder(orderId);
          print(
            'Order ${orderId} cancelled due to timeout (no shipper accepted within 1 minute)',
          );

          // Send notification to customer about cancellation
          _sendCancellationNotificationToCustomer(orderId);
        } else {
          print('Order ${orderId} was accepted by a shipper before timeout');
        }
      } catch (e) {
        print('Error checking order timeout: $e');
      }
    });
  }

  /// Send cancellation notification to customer
  void _sendCancellationNotificationToCustomer(String orderId) {
    // TODO: Implement push notification to customer
    print(
      'NOTIFICATION TO CUSTOMER: Order ${orderId} has been cancelled due to no available shipper within 1 minute.',
    );
  }

  @override
  void onClose() {
    _authController?.removeListener(_onAuthStateChanged);
    super.onClose();
  }
}
