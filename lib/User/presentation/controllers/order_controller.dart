import 'package:flutter/material.dart';
import 'package:mobile/User/data/repositories/order_repository.dart';
import 'package:mobile/User/domain/models/order.dart' as order_model;
import 'package:mobile/User/domain/models/cart_item.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';

enum OrderState { initial, loading, success, error }

class OrderController extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final AuthController? _authController;

  List<order_model.Order> _orders = [];
  order_model.Order? _currentOrder;
  OrderState _state = OrderState.initial;
  String? _errorMessage;
  bool _isLoading = false;
  String? _currentUserId;

  // Getters
  List<order_model.Order> get orders => List.unmodifiable(_orders.reversed);
  order_model.Order? get currentOrder => _currentOrder;
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

      List<order_model.Order> orders = await _orderRepository.getUserOrders(
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
  Future<bool> createOrder(List<CartItem> items, double totalPrice) async {
    print('createOrder called - userId: $_currentUserId, items: ${items.length}');
    
    if (_currentUserId == null) {
      _errorMessage = 'Lỗi: Bạn chưa đăng nhập';
      notifyListeners();
      print('Error: userId is null');
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      order_model.Order order = await _orderRepository.createOrder(
        userId: _currentUserId!,
        items: items,
        totalPrice: totalPrice,
      );

      _orders.add(order);
      _currentOrder = order;
      _state = OrderState.success;
      _setLoading(false);
      notifyListeners();
      print('Order created successfully');
      return true;
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

      order_model.Order? order = await _orderRepository.getOrderById(orderId);

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
  Future<List<order_model.Order>> getOrdersByStatus(String status) async {
    try {
      return await _orderRepository.getOrdersByStatus(status);
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = OrderState.error;
      notifyListeners();
      return [];
    }
  }

  /// Get pending orders
  Future<List<order_model.Order>> getPendingOrders() async {
    return await getOrdersByStatus('pending');
  }

  /// Get completed orders
  Future<List<order_model.Order>> getCompletedOrders() async {
    return await getOrdersByStatus('completed');
  }

  /// Get cancelled orders
  Future<List<order_model.Order>> getCancelledOrders() async {
    return await getOrdersByStatus('cancelled');
  }

  /// Get order count by status
  int getOrderCountByStatus(String status) {
    return _orders.where((order) => order.status == status).length;
  }

  /// Get total spent
  double getTotalSpent() {
    return _orders
        .where((order) => order.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  /// Get recent orders (last 10)
  List<order_model.Order> getRecentOrders({int limit = 10}) {
    return _orders.take(limit).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
