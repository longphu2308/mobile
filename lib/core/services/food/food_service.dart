import 'package:get/get.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/repositories/food_repository.dart';

class FoodService extends GetxController {
  final FoodRepository _foodRepository;
  final RxList<FoodModel> _foods = <FoodModel>[].obs;
  final RxList<FoodModel> _filteredFoods = <FoodModel>[].obs;
  final RxBool _isLoading = false.obs;

  FoodService({FoodRepository? foodRepository})
    : _foodRepository = foodRepository ?? FoodRepository() {
    loadFoods();
  }

  List<FoodModel> get foods => _foods;
  List<FoodModel> get filteredFoods => _filteredFoods;
  bool get isLoading => _isLoading.value;

  Future<void> loadFoods() async {
    _isLoading.value = true;

    try {
      print('FoodService: Starting to load foods...');
      final foods = await _foodRepository.getAllFoods();
      print('FoodService: Loaded ${foods.length} foods from repository');
      _foods.clear();
      _foods.addAll(foods);
      _filteredFoods.clear();
      _filteredFoods.addAll(foods);
      print('FoodService: Foods in memory: ${_foods.length}');
    } catch (e) {
      print('Error loading foods: $e');
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
