import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/firebase/firebase_service.dart';
import 'package:mobile/User/domain/models/order.dart' as order_model;
import 'package:mobile/User/domain/models/cart_item.dart';

class OrderRepository {
  final FirebaseService _firebaseService;

  OrderRepository({FirebaseService? firebaseService})
    : _firebaseService = firebaseService ?? FirebaseService();

  /// Create a new order
  Future<order_model.Order> createOrder({
    required String userId,
    required List<CartItem> items,
    required double totalPrice,
  }) async {
    try {
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      order_model.Order order = order_model.Order(
        id: orderId,
        userId: userId,
        items: items,
        totalPrice: totalPrice,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      print('Creating order with ID: $orderId');
      print('Order data: ${order.toMap()}');

      await _firebaseService.firestore
          .collection('orders')
          .doc(orderId)
          .set(order.toMap());

      print('Order created successfully');
      return order;
    } catch (e) {
      print('Error creating order: $e');
      throw FirestoreException(
        message: 'Lỗi tạo đơn hàng: ${e.toString()}',
        code: 'create_order_error',
      );
    }
  }

  /// Get orders for a user
  Future<List<order_model.Order>> getUserOrders(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query = await _firebaseService
          .firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => order_model.Order.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy danh sách đơn hàng: ${e.toString()}',
        code: 'get_orders_error',
      );
    }
  }

  /// Get order by ID
  Future<order_model.Order?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _firebaseService
          .firestore
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists && doc.data() != null) {
        return order_model.Order.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy thông tin đơn hàng: ${e.toString()}',
        code: 'get_order_error',
      );
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firebaseService.firestore.collection('orders').doc(orderId).update(
        {'status': status, 'updatedAt': DateTime.now()},
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi cập nhật trạng thái đơn hàng: ${e.toString()}',
        code: 'update_order_status_error',
      );
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, 'cancelled');
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi hủy đơn hàng: ${e.toString()}',
        code: 'cancel_order_error',
      );
    }
  }

  /// Get all orders (for admin)
  Future<List<order_model.Order>> getAllOrders() async {
    try {
      QuerySnapshot<Map<String, dynamic>> query = await _firebaseService
          .firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => order_model.Order.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy tất cả đơn hàng: ${e.toString()}',
        code: 'get_all_orders_error',
      );
    }
  }

  /// Get orders by status
  Future<List<order_model.Order>> getOrdersByStatus(String status) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query = await _firebaseService
          .firestore
          .collection('orders')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => order_model.Order.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy đơn hàng theo trạng thái: ${e.toString()}',
        code: 'get_orders_by_status_error',
      );
    }
  }
}
