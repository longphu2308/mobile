import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class FoodRepository {
  final SupabaseService _supabase = SupabaseService();

  // Lấy tất cả món ăn
  Future<List<FoodModel>> getAllFoods() async {
    try {
      print('\n🍽️ FoodRepository.getAllFoods START ============');
      print('📡 Fetching foods from Supabase...');

      final response = await _supabase.from('foods').select();

      print('📦 Response type: ${response.runtimeType}');
      print('📊 Response length: ${response.length}');

      if (response.isEmpty) {
        print('⚠️ WARNING: No foods returned from database!');
        print('   Possible causes:');
        print('   1. No foods exist in database');
        print('   2. RLS policy blocking access');
        print('   3. User not authenticated');
        return [];
      }

      final foods = (response as List).map((data) {
        print('  ✅ Food: ${data['name']} (ID: ${data['food_id']})');
        return FoodModel.fromMap(data, data['food_id']);
      }).toList();

      print('🎉 Successfully loaded ${foods.length} foods');
      print('🍽️ FoodRepository.getAllFoods END ============\n');
      return foods;
    } catch (e, stackTrace) {
      print('\n❌ ERROR in FoodRepository.getAllFoods:');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      print('🍽️ FoodRepository.getAllFoods END (with error) ============\n');
      return [];
    }
  }

  // Lấy món ăn theo restaurant
  Future<List<FoodModel>> getFoodsByRestaurant(String restaurantId) async {
    try {
      final response = await _supabase
          .from('foods')
          .select()
          .eq('restaurant_id', restaurantId);

      return (response as List)
          .map((data) => FoodModel.fromMap(data, data['food_id']))
          .toList();
    } catch (e) {
      print('Error getting foods by restaurant: $e');
      return [];
    }
  }

  // Lấy món ăn theo category
  Future<List<FoodModel>> getFoodsByCategory(
    String restaurantId,
    String category,
  ) async {
    try {
      final response = await _supabase
          .from('foods')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('category', category);

      return (response as List)
          .map((data) => FoodModel.fromMap(data, data['food_id']))
          .toList();
    } catch (e) {
      print('Error getting foods by category: $e');
      return [];
    }
  }

  // Lấy món ăn còn hàng
  Future<List<FoodModel>> getAvailableFoods(String restaurantId) async {
    try {
      final response = await _supabase
          .from('foods')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('available', true);

      return (response as List)
          .map((data) => FoodModel.fromMap(data, data['food_id']))
          .toList();
    } catch (e) {
      print('Error getting available foods: $e');
      return [];
    }
  }

  // Lấy món ăn theo ID
  Future<FoodModel?> getFoodById(String foodId) async {
    try {
      final response = await _supabase
          .from('foods')
          .select()
          .eq('food_id', foodId)
          .maybeSingle();

      if (response != null) {
        return FoodModel.fromMap(response, foodId);
      }
      return null;
    } catch (e) {
      print('Error getting food: $e');
      return null;
    }
  }

  // Tìm kiếm món ăn theo tên, mô tả, hoặc category
  Future<List<FoodModel>> searchFoods(
    String query, {
    String? restaurantId,
  }) async {
    try {
      print('🔍 Searching foods for: "$query"');
      var queryBuilder = _supabase.from('foods').select();

      if (restaurantId != null) {
        queryBuilder = queryBuilder.eq('restaurant_id', restaurantId);
      }

      // Tìm kiếm theo tên (case-insensitive)
      final response = await queryBuilder.or(
        'name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%',
      );

      final results = (response as List)
          .map((data) => FoodModel.fromMap(data, data['food_id']))
          .toList();

      print('✅ Found ${results.length} foods');
      return results;
    } catch (e, stackTrace) {
      print('❌ Error searching foods: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Tạo món ăn mới
  Future<String?> createFood(FoodModel food) async {
    try {
      final response = await _supabase
          .from('foods')
          .insert(food.toMap())
          .select()
          .single();

      return response['food_id'];
    } catch (e) {
      print('Error creating food: $e');
      return null;
    }
  }

  // Cập nhật món ăn
  Future<bool> updateFood(String foodId, Map<String, dynamic> data) async {
    try {
      // Convert camelCase to snake_case if needed
      final snakeCaseData = <String, dynamic>{};
      data.forEach((key, value) {
        final snakeKey = key.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        );
        snakeCaseData[snakeKey] = value;
      });

      snakeCaseData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('foods').update(snakeCaseData).eq('food_id', foodId);

      return true;
    } catch (e) {
      print('Error updating food: $e');
      return false;
    }
  }

  // Cập nhật trạng thái available
  Future<bool> updateFoodAvailability(String foodId, bool available) async {
    try {
      await _supabase
          .from('foods')
          .update({
            'available': available,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('food_id', foodId);

      return true;
    } catch (e) {
      print('Error updating food availability: $e');
      return false;
    }
  }

  // Xóa món ăn
  Future<bool> deleteFood(String foodId) async {
    try {
      await _supabase.from('foods').delete().eq('food_id', foodId);

      return true;
    } catch (e) {
      print('Error deleting food: $e');
      rethrow; // Rethrow để controller có thể bắt và xử lý soft delete
    }
  }

  // Stream để lắng nghe thay đổi món ăn của quán
  Stream<List<FoodModel>> foodsStream(String restaurantId) {
    return _supabase
        .from('foods')
        .stream(primaryKey: ['food_id'])
        .eq('restaurant_id', restaurantId)
        .map(
          (data) => (data as List)
              .map((item) => FoodModel.fromMap(item, item['food_id']))
              .toList(),
        );
  }
}
