import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/models/favorite_model.dart';
import 'package:mobile/core/models/food_model.dart';

class FavoriteRepository {
  final _supabase = SupabaseService().client;

  /// Get all favorites for a user
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    try {
      final data = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => FavoriteModel.fromMap(item, item['favorite_id']))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy danh sách yêu thích: ${e.toString()}',
        code: 'get_favorites_error',
      );
    }
  }

  /// Add food to favorites
  Future<bool> addFavorite(String userId, FoodModel food) async {
    try {
      // Check if already favorited
      final existing = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('food_id', food.id)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        return false; // Already favorited
      }

      final favoriteData = {
        'user_id': userId,
        'food_id': food.id,
        'food_name': food.name,
        'food_image_url': food.imageUrl,
        'price': food.price,
        'restaurant_id': food.restaurantId,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('favorites').insert(favoriteData);

      return true;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi thêm vào yêu thích: ${e.toString()}',
        code: 'add_favorite_error',
      );
    }
  }

  /// Remove food from favorites
  Future<bool> removeFavorite(String userId, String foodId) async {
    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('food_id', foodId);
      return true;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi xóa khỏi yêu thích: ${e.toString()}',
        code: 'remove_favorite_error',
      );
    }
  }

  /// Check if food is favorited
  Future<bool> isFavorited(String userId, String foodId) async {
    try {
      final data = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('food_id', foodId)
          .limit(1)
          .maybeSingle();

      return data != null;
    } catch (e) {
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String userId, FoodModel food) async {
    final isFav = await isFavorited(userId, food.id);
    if (isFav) {
      return await removeFavorite(userId, food.id);
    } else {
      return await addFavorite(userId, food);
    }
  }

  /// Stream để lắng nghe thay đổi của favorites
  Stream<List<FavoriteModel>> favoritesStream(String userId) {
    return _supabase
        .from('favorites')
        .stream(primaryKey: ['favorite_id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((item) => FavoriteModel.fromMap(item, item['favorite_id']))
            .toList());
  }
}
