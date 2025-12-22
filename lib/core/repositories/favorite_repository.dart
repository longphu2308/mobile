import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/models/favorite_model.dart';
import 'package:mobile/core/models/food_model.dart';

class FavoriteRepository {
  final _supabase = SupabaseService().client;

  /// Get all favorites for a user
  /// Join with foods table to get food details
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    try {
      // First get favorites
      final favoritesData = await _supabase
          .from('favorites')
          .select('favorite_id, user_id, food_id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (favoritesData.isEmpty) {
        return [];
      }

      // Get all food IDs
      final foodIds = (favoritesData as List)
          .map((item) => item['food_id'] as String)
          .toList();

      // Fetch foods data
      final foodsData = await _supabase
          .from('foods')
          .select('food_id, name, image_url, price, restaurant_id')
          .inFilter('food_id', foodIds);

      // Create a map for quick lookup
      final foodsMap = <String, Map<String, dynamic>>{};
      for (var food in foodsData as List) {
        foodsMap[food['food_id'] as String] = food;
      }

      // Get restaurant names if needed
      final restaurantIds = foodsMap.values
          .where((f) => f['restaurant_id'] != null)
          .map((f) => f['restaurant_id'] as String)
          .toSet()
          .toList();

      final restaurantsMap = <String, String>{};
      if (restaurantIds.isNotEmpty) {
        final restaurantsData = await _supabase
            .from('restaurants')
            .select('restaurant_id, name')
            .inFilter('restaurant_id', restaurantIds);

        for (var restaurant in restaurantsData as List) {
          restaurantsMap[restaurant['restaurant_id'] as String] =
              restaurant['name'] as String;
        }
      }

      // Combine data
      return (favoritesData as List).map((item) {
        final favoriteId = item['favorite_id'] as String;
        final foodId = item['food_id'] as String;
        final foodData = foodsMap[foodId];

        if (foodData == null) {
          // Food might have been deleted
          return FavoriteModel(
            id: favoriteId,
            userId: item['user_id'] ?? '',
            foodId: foodId,
            foodName: 'Món ăn không còn tồn tại',
            foodImageUrl: '',
            price: 0,
            createdAt: item['created_at'] != null
                ? DateTime.parse(item['created_at'])
                : DateTime.now(),
          );
        }

        return FavoriteModel(
          id: favoriteId,
          userId: item['user_id'] ?? '',
          foodId: foodId,
          foodName: foodData['name'] ?? '',
          foodImageUrl: foodData['image_url'] ?? '',
          price: (foodData['price'] ?? 0).toDouble(),
          restaurantId: foodData['restaurant_id'],
          restaurantName: foodData['restaurant_id'] != null
              ? restaurantsMap[foodData['restaurant_id']]
              : null,
          createdAt: item['created_at'] != null
              ? DateTime.parse(item['created_at'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('❌ Error getting favorites: $e');
      throw FirestoreException(
        message: 'Lỗi lấy danh sách yêu thích: ${e.toString()}',
        code: 'get_favorites_error',
      );
    }
  }

  /// Add food to favorites
  /// Only stores user_id and food_id (schema only has these columns)
  Future<bool> addFavorite(String userId, FoodModel food) async {
    try {
      // Check if already favorited
      final existing = await _supabase
          .from('favorites')
          .select('favorite_id')
          .eq('user_id', userId)
          .eq('food_id', food.id)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        return false; // Already favorited
      }

      // Only insert columns that exist in the schema
      final favoriteData = {'user_id': userId, 'food_id': food.id};

      await _supabase.from('favorites').insert(favoriteData);

      return true;
    } catch (e) {
      print('❌ Error adding favorite: $e');
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
  /// Join with foods table to get food details
  Stream<List<FavoriteModel>> favoritesStream(String userId) {
    return _supabase
        .from('favorites')
        .stream(primaryKey: ['favorite_id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          // Note: Stream doesn't support joins well, so we'll need to fetch food details separately
          // For now, return basic favorite info
          return data.map((item) {
            final favoriteId = item['favorite_id'] as String;
            return FavoriteModel(
              id: favoriteId,
              userId: item['user_id'] ?? '',
              foodId: item['food_id'] ?? '',
              foodName:
                  'Loading...', // Will be updated when food details are fetched
              foodImageUrl: '',
              price: 0,
              createdAt: item['created_at'] != null
                  ? DateTime.parse(item['created_at'])
                  : DateTime.now(),
            );
          }).toList();
        });
  }
}
