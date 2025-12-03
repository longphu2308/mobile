import 'package:flutter/foundation.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/repositories/food_repository.dart';

class FoodService extends ChangeNotifier {
  final FoodRepository _foodRepository;
  final List<FoodModel> _foods = [];
  final List<FoodModel> _filteredFoods = [];
  bool _isLoading = false;

  FoodService({FoodRepository? foodRepository})
    : _foodRepository = foodRepository ?? FoodRepository() {
    loadFoods();
  }

  List<FoodModel> get foods => List.unmodifiable(_foods);
  List<FoodModel> get filteredFoods => List.unmodifiable(_filteredFoods);
  bool get isLoading => _isLoading;

  Future<void> loadFoods() async {
    _isLoading = true;
    notifyListeners();

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
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(String category) {
    _filteredFoods.clear();
    _filteredFoods.addAll(
      _foods.where((food) => food.category == category).toList(),
    );
    notifyListeners();
  }

  Future<void> loadFoodsByRestaurantAndCategory(
    String restaurantId,
    String category,
  ) async {
    _isLoading = true;
    notifyListeners();

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
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFoods(String query) async {
    if (query.isEmpty) {
      _filteredFoods.clear();
      _filteredFoods.addAll(_foods);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final foods = await _foodRepository.searchFoods(query);
      _filteredFoods.clear();
      _filteredFoods.addAll(foods);
    } catch (e) {
      print('Error searching foods: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _filteredFoods.clear();
    _filteredFoods.addAll(_foods);
    notifyListeners();
  }
}
