import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/models/user_model.dart';

class OrderRepository {
  final _supabase = SupabaseService().client;
  final String _table = 'orders';

  // Lấy tất cả orders của user
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((item) => OrderModel.fromMap(item, item['order_id']))
          .toList();
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  // Lấy tất cả orders của restaurant (cho owner)
  Future<List<OrderModel>> getRestaurantOrders(String restaurantId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((item) => OrderModel.fromMap(item, item['order_id']))
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
      final data = await _supabase
          .from(_table)
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('status', status)
          .order('created_at', ascending: false);
      return (data as List)
          .map((item) => OrderModel.fromMap(item, item['order_id']))
          .toList();
    } catch (e) {
      print('Error getting restaurant orders by status: $e');
      return [];
    }
  }

  // Lấy order theo ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('order_id', orderId)
          .maybeSingle();
      if (data != null) {
        return OrderModel.fromMap(data, data['order_id']);
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
      final data = await _supabase
          .from(_table)
          .insert(order.toMap())
          .select()
          .single();
      return data['order_id'];
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Cập nhật status của order
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from(_table)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Cập nhật order
  Future<bool> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _supabase.from(_table).update(data).eq('order_id', orderId);
      return true;
    } catch (e) {
      print('Error updating order: $e');
      return false;
    }
  }

  // Hủy order
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _supabase
          .from(_table)
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  // Stream để lắng nghe orders của user
  Stream<List<OrderModel>> userOrdersStream(String userId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['order_id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .map((item) => OrderModel.fromMap(item, item['order_id']))
              .toList(),
        );
  }

  // Stream để lắng nghe orders của restaurant
  Stream<List<OrderModel>> restaurantOrdersStream(String restaurantId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['order_id'])
        .eq('restaurant_id', restaurantId)
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .map((item) => OrderModel.fromMap(item, item['order_id']))
              .toList(),
        );
  }

  // Tính tổng doanh thu của restaurant
  Future<double> calculateRestaurantRevenue(String restaurantId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('status', 'delivered');

      double total = 0;
      for (var item in data) {
        final order = OrderModel.fromMap(item, item['order_id']);
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
      final data = await _supabase
          .from(_table)
          .select()
          .eq('restaurant_id', restaurantId);

      Map<String, int> counts = {
        'pending': 0,
        'preparing': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (var item in data) {
        final order = OrderModel.fromMap(item, item['order_id']);
        final statusKey = order.status.value;
        counts[statusKey] = (counts[statusKey] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error counting orders: $e');
      return {};
    }
  }

  // Get available shippers
  Future<List<ShipperProfileModel>> getAvailableShippers() async {
    try {
      final data = await _supabase
          .from('shipper_profiles')
          .select()
          .eq('is_available', true);
      return (data as List)
          .map((item) => ShipperProfileModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Error getting available shippers: $e');
      return [];
    }
  }

  // Assign shipper to order
  Future<bool> assignShipperToOrder(String orderId, String shipperId) async {
    try {
      await _supabase
          .from(_table)
          .update({'shipper_id': shipperId})
          .eq('order_id', orderId);
      return true;
    } catch (e) {
      print('Error assigning shipper: $e');
      return false;
    }
  }

  // Get orders by shipper
  Future<List<OrderModel>> getOrdersByShipper(String shipperId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('shipper_id', shipperId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((item) => OrderModel.fromMap(item, item['order_id']))
          .toList();
    } catch (e) {
      print('Error getting shipper orders: $e');
      return [];
    }
  }

  // Get orders by status (global, for shipper to find available orders)
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);
      return (data as List)
          .map((item) => OrderModel.fromMap(item, item['order_id']))
          .toList();
    } catch (e) {
      print('Error getting orders by status: $e');
      return [];
    }
  }

  // Stream for shipper orders
  Stream<List<OrderModel>> shipperOrdersStream(String shipperId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['order_id'])
        .eq('shipper_id', shipperId)
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .map((item) => OrderModel.fromMap(item, item['order_id']))
              .toList(),
        );
  }
}
