import 'package:flutter/material.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/core/models/cart_model.dart';

enum OrderState { initial, loading, success, error }

class OrderController extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final AuthController? _authController;

  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  OrderState _state = OrderState.initial;
  String? _errorMessage;
  bool _isLoading = false;
  String? _currentUserId;

  // Getters
  List<OrderModel> get orders => List.unmodifiable(_orders.reversed);
  OrderModel? get currentOrder => _currentOrder;
  OrderState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

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
      notifyListeners();
    }
  }

  /// Load user's orders from Firebase
  Future<void> loadUserOrders() async {
    if (_currentUserId == null) return;

    try {
      _setLoading(true);
      _errorMessage = null;

      List<OrderModel> orders = await _orderRepository.getUserOrders(
        _currentUserId!,
      );
      _orders = orders;
      _state = OrderState.success;
      _setLoading(false);
      notifyListeners();
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = OrderState.error;
      _setLoading(false);
      notifyListeners();
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
    print(
      'createOrder called - userId: $_currentUserId, items: ${items.length}',
    );

    if (_currentUserId == null) {
      _errorMessage = 'Lỗi: Bạn chưa đăng nhập';
      notifyListeners();
      print('Error: userId is null');
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

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

      // Create order model
      final order = OrderModel(
        id: '', // Will be set by Firestore
        userId: _currentUserId!,
        restaurantId: restaurantId,
        items: orderItems,
        totalAmount: totalAmount,
        status: 'pending',
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        note: note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final orderId = await _orderRepository.createOrder(order);

      if (orderId != null) {
        final createdOrder = order.copyWith(id: orderId);
        _orders.add(createdOrder);
        _currentOrder = createdOrder;
        _state = OrderState.success;
        _setLoading(false);
        notifyListeners();
        print('Order created successfully');
        return true;
      } else {
        _errorMessage = 'Không thể tạo đơn hàng';
        _state = OrderState.error;
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = OrderState.error;
      _setLoading(false);
      notifyListeners();
      print('FirestoreException: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi: ${e.toString()}';
      _state = OrderState.error;
      _setLoading(false);
      notifyListeners();
      print('Error creating order: $e');
      return false;
    }
  }

  /// Get order by ID
  Future<bool> getOrderById(String orderId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      OrderModel? order = await _orderRepository.getOrderById(orderId);

      if (order != null) {
        _currentOrder = order;
        _state = OrderState.success;
      } else {
        _state = OrderState.error;
        _errorMessage = 'Đơn hàng không tồn tại';
      }
      _setLoading(false);
      notifyListeners();
      return order != null;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = OrderState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _orderRepository.updateOrderStatus(orderId, status);

      // Update local state
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(status: status);
      }

      if (_currentOrder?.id == orderId) {
        _currentOrder = _currentOrder!.copyWith(status: status);
      }

      _state = OrderState.success;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = OrderState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, 'cancelled');
  }

  /// Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      return _orders.where((order) => order.status == status).toList();
    } catch (e) {
      _errorMessage = e.toString();
      _state = OrderState.error;
      notifyListeners();
      return [];
    }
  }

  /// Get pending orders
  Future<List<OrderModel>> getPendingOrders() async {
    return await getOrdersByStatus('pending');
  }

  /// Get completed orders
  Future<List<OrderModel>> getCompletedOrders() async {
    return await getOrdersByStatus('delivered');
  }

  /// Get cancelled orders
  Future<List<OrderModel>> getCancelledOrders() async {
    return await getOrdersByStatus('cancelled');
  }

  /// Get order count by status
  int getOrderCountByStatus(String status) {
    return _orders.where((order) => order.status == status).length;
  }

  /// Get total spent
  double getTotalSpent() {
    return _orders
        .where((order) => order.status == 'delivered')
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  /// Get recent orders (last 10)
  List<OrderModel> getRecentOrders({int limit = 10}) {
    return _orders.take(limit).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authController?.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
