import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/food_repository.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/models/restaurant_model.dart';

class MenuScreenController extends GetxController {
  final Color primaryColor = const Color(0xFFFF6B1D);
  final FoodRepository _foodRepository = FoodRepository();
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final _supabase = SupabaseService();

  final Rx<RestaurantModel?> _restaurant = Rx<RestaurantModel?>(null);
  final RxList<FoodModel> _menu = <FoodModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString(null);

  // Danh mục món - Map category key to Vietnamese
  static const Map<String, String> categoryMap = {
    'all': 'Tất cả',
    'appetizer': 'Khai vị',
    'main': 'Món chính',
    'dessert': 'Tráng miệng',
    'drink': 'Đồ uống',
    'combo': 'Combo',
  };

  List<String> get categoryKeys => categoryMap.keys.toList();
  final RxString _selectedCategoryKey = 'all'.obs;

  String get selectedCategoryKey => _selectedCategoryKey.value;
  String get selectedCategoryLabel =>
      categoryMap[_selectedCategoryKey.value] ?? 'Tất cả';
  List<FoodModel> get menu => _menu;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  RestaurantModel? get restaurant => _restaurant.value;

  /// Convert category key to Vietnamese label
  static String getCategoryLabel(String categoryKey) {
    return categoryMap[categoryKey] ?? categoryKey;
  }

  List<FoodModel> get filteredMenu {
    if (_selectedCategoryKey.value == 'all') return _menu;
    return _menu
        .where((m) => m.category == _selectedCategoryKey.value)
        .toList();
  }

  // Load menu của restaurant
  Future<void> loadMenu() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) {
        _error.value = 'User not authenticated';
        return;
      }

      // Lấy restaurant của owner
      _restaurant.value = await _restaurantRepository.getRestaurantByOwnerId(
        userId,
      );

      if (_restaurant.value == null) {
        _error.value = 'Restaurant not found';
        return;
      }

      // Lấy tất cả món ăn của restaurant
      _menu.assignAll(
        await _foodRepository.getFoodsByRestaurant(_restaurant.value!.id),
      );
    } catch (e) {
      _error.value = 'Error loading menu: $e';
      print(_error.value);
    } finally {
      _isLoading.value = false;
    }
  }

  void selectCategory(String categoryKey) {
    _selectedCategoryKey.value = categoryKey;
  }

  Future<void> toggleAvailability(String foodId, bool currentAvailable) async {
    try {
      final success = await _foodRepository.updateFoodAvailability(
        foodId,
        !currentAvailable,
      );

      if (success) {
        final index = _menu.indexWhere((f) => f.id == foodId);
        if (index >= 0) {
          _menu[index] = _menu[index].copyWith(available: !currentAvailable);
        }
      }
    } catch (e) {
      print('Error toggling availability: $e');
    }
  }

  Future<void> deleteItem(String foodId) async {
    try {
      final success = await _foodRepository.deleteFood(foodId);

      if (success) {
        _menu.removeWhere((item) => item.id == foodId);
      }
    } catch (e) {
      print('Error deleting food: $e');
    }
  }

  Future<bool> addItem(FoodModel food) async {
    if (_restaurant.value == null) {
      throw Exception('Restaurant not found');
    }

    try {
      final foodId = await _foodRepository.createFood(food);

      if (foodId != null) {
        _menu.add(food.copyWith(id: foodId));
        return true;
      } else {
        throw Exception('Failed to create food');
      }
    } catch (e) {
      print('Error adding food: $e');
      rethrow;
    }
  }

  Future<bool> updateItem(String foodId, FoodModel updatedFood) async {
    try {
      final success = await _foodRepository.updateFood(
        foodId,
        updatedFood.toMap(),
      );

      if (success) {
        final idx = _menu.indexWhere((i) => i.id == foodId);
        if (idx != -1) {
          _menu[idx] = updatedFood.copyWith(id: foodId);
        }
        return true;
      } else {
        throw Exception('Failed to update food');
      }
    } catch (e) {
      print('Error updating food: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadMenu();
  }
}
