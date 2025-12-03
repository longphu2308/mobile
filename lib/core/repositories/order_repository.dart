import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // Lấy tất cả orders của user
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  // Lấy tất cả orders của restaurant (cho owner)
  Future<List<OrderModel>> getRestaurantOrders(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting restaurant orders: $e');
      return [];
    }
  }

  // Lấy orders theo status (cho owner)
  Future<List<OrderModel>> getRestaurantOrdersByStatus(
    String restaurantId,
    String status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting restaurant orders by status: $e');
      return [];
    }
  }

  // Lấy order theo ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Tạo order mới
  Future<String?> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(order.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Cập nhật status của order
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Cập nhật order
  Future<bool> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order: $e');
      return false;
    }
  }

  // Hủy order
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  // Stream để lắng nghe orders của user
  Stream<List<OrderModel>> userOrdersStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Stream để lắng nghe orders của restaurant
  Stream<List<OrderModel>> restaurantOrdersStream(String restaurantId) {
    return _firestore
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Tính tổng doanh thu của restaurant
  Future<double> calculateRestaurantRevenue(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('status', isEqualTo: 'delivered')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final order = OrderModel.fromMap(doc.data(), doc.id);
        total += order.totalAmount;
      }
      return total;
    } catch (e) {
      print('Error calculating revenue: $e');
      return 0;
    }
  }

  // Đếm số orders theo status
  Future<Map<String, int>> countOrdersByStatus(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      Map<String, int> counts = {
        'pending': 0,
        'preparing': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (var doc in snapshot.docs) {
        final order = OrderModel.fromMap(doc.data(), doc.id);
        counts[order.status] = (counts[order.status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error counting orders: $e');
      return {};
    }
  }
}
