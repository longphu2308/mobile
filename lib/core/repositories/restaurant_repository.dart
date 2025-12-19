import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class RestaurantRepository {
  final _supabase = SupabaseService().client;
  final String _table = 'restaurants';

  // Lấy thông tin quán theo ID
  Future<RestaurantModel?> getRestaurantById(String restaurantId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      if (data != null) {
        return RestaurantModel.fromMap(data, data['restaurant_id']);
      }
      return null;
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // Lấy quán của owner
  Future<RestaurantModel?> getRestaurantByOwnerId(String ownerId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('owner_id', ownerId)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        return RestaurantModel.fromMap(data, data['restaurant_id']);
      }
      return null;
    } catch (e) {
      print('Error getting restaurant by owner: $e');
      return null;
    }
  }

  // Lấy tất cả quán
  Future<List<RestaurantModel>> getAllRestaurants() async {
    try {
      final data = await _supabase.from(_table).select();
      return (data as List)
          .map((item) => RestaurantModel.fromMap(item, item['restaurant_id']))
          .toList();
    } catch (e) {
      print('Error getting all restaurants: $e');
      return [];
    }
  }

  // Lấy các quán đang mở
  Future<List<RestaurantModel>> getOpenRestaurants() async {
    try {
      final data = await _supabase.from(_table).select().eq('status', 'open');
      return (data as List)
          .map((item) => RestaurantModel.fromMap(item, item['restaurant_id']))
          .toList();
    } catch (e) {
      print('Error getting open restaurants: $e');
      return [];
    }
  }

  // Tạo quán mới
  Future<String?> createRestaurant(RestaurantModel restaurant) async {
    try {
      final data = await _supabase
          .from(_table)
          .insert(restaurant.toMap())
          .select()
          .single();
      return data['restaurant_id'];
    } catch (e) {
      print('Error creating restaurant: $e');
      return null;
    }
  }

  // Cập nhật thông tin quán
  Future<bool> updateRestaurant(
    String restaurantId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _supabase
          .from(_table)
          .update(data)
          .eq('restaurant_id', restaurantId);
      return true;
    } catch (e) {
      print('Error updating restaurant: $e');
      return false;
    }
  }

  // Cập nhật trạng thái quán (open/closed)
  Future<bool> updateRestaurantStatus(
    String restaurantId,
    String status,
  ) async {
    try {
      await _supabase
          .from(_table)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('restaurant_id', restaurantId);
      return true;
    } catch (e) {
      print('Error updating restaurant status: $e');
      return false;
    }
  }

  // Xóa quán
  Future<bool> deleteRestaurant(String restaurantId) async {
    try {
      await _supabase.from(_table).delete().eq('restaurant_id', restaurantId);
      return true;
    } catch (e) {
      print('Error deleting restaurant: $e');
      return false;
    }
  }

  // Stream để lắng nghe thay đổi của quán
  Stream<RestaurantModel?> restaurantStream(String restaurantId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['restaurant_id'])
        .eq('restaurant_id', restaurantId)
        .map((data) {
          if (data.isNotEmpty) {
            return RestaurantModel.fromMap(
              data.first,
              data.first['restaurant_id'],
            );
          }
          return null;
        });
  }
}
