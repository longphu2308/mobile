import 'package:get/get.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/repositories/food_repository.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class FoodService extends GetxController {
  final FoodRepository _foodRepository;
  final RxList<FoodModel> _foods = <FoodModel>[].obs;
  final RxList<FoodModel> _filteredFoods = <FoodModel>[].obs;
  final RxBool _isLoading = false.obs;

  FoodService({FoodRepository? foodRepository})
    : _foodRepository = foodRepository ?? FoodRepository();
  
  @override
  void onInit() {
    super.onInit();
    // Don't load foods in constructor - wait for user to authenticate
    // Foods will be loaded after successful login or when home screen appears
  }

  List<FoodModel> get foods => _foods;
  List<FoodModel> get filteredFoods => _filteredFoods;
  bool get isLoading => _isLoading.value;

  Future<void> loadFoods() async {
    _isLoading.value = true;

    try {
      print('\n🔄 FoodService.loadFoods START ============');
      
      // Check if user is authenticated
      final supabase = SupabaseService();
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        print('❌ ERROR: User not authenticated!');
        print('   Cannot load foods without authentication');
        print('🔄 FoodService.loadFoods END (no auth) ============\n');
        return;
      }
      
      print('✅ User authenticated: ${currentUser.email}');
      print('📞 Calling FoodRepository.getAllFoods()...');
      
      final foods = await _foodRepository.getAllFoods();
      
      print('📦 Received ${foods.length} foods from repository');
      
      _foods.clear();
      _foods.addAll(foods);
      _filteredFoods.clear();
      _filteredFoods.addAll(foods);
      
      print('💾 Foods stored in memory:');
      print('   - _foods: ${_foods.length}');
      print('   - _filteredFoods: ${_filteredFoods.length}');
      
      if (foods.isEmpty) {
        print('⚠️ WARNING: No foods loaded!');
        print('   Check:');
        print('   1. Database has foods');
        print('   2. RLS policies allow access');
        print('   3. Restaurants exist');
      } else {
        print('🎉 Successfully loaded foods');
        print('   Sample: ${_foods.take(3).map((f) => f.name).join(", ")}...');
      }
      
      print('🔄 FoodService.loadFoods END ============\n');
    } catch (e, stackTrace) {
      print('\n❌ ERROR in FoodService.loadFoods:');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      print('🔄 FoodService.loadFoods END (with error) ============\n');
    } finally {
      _isLoading.value = false;
    }
  }

  void filterByCategory(String category) {
    _filteredFoods.clear();
    _filteredFoods.addAll(
      _foods.where((food) => food.category == category).toList(),
    );
  }

  Future<void> loadFoodsByRestaurantAndCategory(
    String restaurantId,
    String category,
  ) async {
    _isLoading.value = true;

    try {
      final foods = await _foodRepository.getFoodsByCategory(
        restaurantId,
        category,
      );
      _filteredFoods.clear();
      _filteredFoods.addAll(foods);
    } catch (e) {
      print('Error loading foods by category: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> searchFoods(String query) async {
    if (query.isEmpty) {
      _filteredFoods.clear();
      _filteredFoods.addAll(_foods);
      return;
    }

    _isLoading.value = true;

    try {
      final foods = await _foodRepository.searchFoods(query);
      _filteredFoods.clear();
      _filteredFoods.addAll(foods);
    } catch (e) {
      print('Error searching foods: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void clearFilters() {
    _filteredFoods.clear();
    _filteredFoods.addAll(_foods);
  }
}
