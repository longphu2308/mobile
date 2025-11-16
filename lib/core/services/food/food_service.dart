import 'package:flutter/foundation.dart';
import 'package:mobile/User/domain/models/food.dart';
import 'package:mobile/User/data/repositories/food_repository.dart';

class FoodService extends ChangeNotifier {
  final FoodRepository _foodRepository;
  final List<Food> _foods = [];
  final List<Food> _filteredFoods = [];
  bool _isLoading = false;

  FoodService({FoodRepository? foodRepository})
    : _foodRepository = foodRepository ?? FoodRepository() {
    loadFoods();
  }

  List<Food> get foods => List.unmodifiable(_foods);
  List<Food> get filteredFoods => List.unmodifiable(_filteredFoods);
  bool get isLoading => _isLoading;

  Future<void> loadFoods() async {
    _isLoading = true;
    notifyListeners();

    try {
      final foods = await _foodRepository.getAllFoods();
      _foods.clear();
      _foods.addAll(foods);
      _filteredFoods.clear();
      _filteredFoods.addAll(foods);
    } catch (e) {
      print('Error loading foods: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFoodsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    try {
      final foods = await _foodRepository.getFoodsByCategory(category);
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
