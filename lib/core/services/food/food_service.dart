import 'package:get/get.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/repositories/food_repository.dart';

class FoodService extends GetxController {
  final FoodRepository _foodRepository;
  final RxList<FoodModel> _foods = <FoodModel>[].obs;
  final RxList<FoodModel> _filteredFoods = <FoodModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxList<String> _categories = <String>[].obs;

  FoodService({FoodRepository? foodRepository})
    : _foodRepository = foodRepository ?? FoodRepository() {
    loadFoods();
  }

  List<FoodModel> get foods => _foods;
  List<FoodModel> get filteredFoods => _filteredFoods;
  bool get isLoading => _isLoading.value;
  List<String> get categories => _categories;

  Future<void> loadFoods() async {
    _isLoading.value = true;
    update(); // Trigger rebuild to show loading

    try {
      print('FoodService: Starting to load foods...');
      final foods = await _foodRepository.getAllFoods();
      print('FoodService: Loaded ${foods.length} foods from repository');
      _foods.clear();
      _foods.addAll(foods);
      _filteredFoods.clear();
      _filteredFoods.addAll(foods);
      
      // Lấy danh sách category unique từ foods
      final uniqueCategories = foods
          .map((food) => food.category)
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      _categories.clear();
      _categories.addAll(uniqueCategories);
      print('FoodService: Foods in memory: ${_foods.length}');
      print('FoodService: Categories found: ${_categories.join(", ")}');
    } catch (e) {
      print('Error loading foods: $e');
    } finally {
      _isLoading.value = false;
      update(); // Trigger rebuild
    }
  }

  void filterByCategory(String category) {
    // Map display names (TabBar titles) to database category values
    // Based on actual database categories: mon_khai_vi, mon_chinh, mon_phu, do_uong, trang_mieng, combo, etc.
    final categoryMap = {
      'Foods': null, // null means show all
      'Drinks': 'do_uong',
      'Snacks': 'mon_khai_vi', // Món khai vị có thể coi như snacks
      'Sauces': 'mon_phu', // Món phụ
      'Desserts': 'trang_mieng',
    };
    
    // Nếu category là category thực tế từ database (bắt đầu bằng 'mon_' hoặc 'do_uong', etc), dùng trực tiếp
    String? categoryValue;
    if (categoryMap.containsKey(category)) {
      categoryValue = categoryMap[category];
      print('Filtering by mapped category: $category -> $categoryValue');
    } else if (_categories.contains(category)) {
      // Nếu category là category thực tế từ database
      categoryValue = category;
      print('Filtering by direct category: $category');
    } else {
      // Thử tìm category không phân biệt hoa thường
      final found = _categories.where(
        (cat) => cat.toLowerCase() == category.toLowerCase(),
      ).firstOrNull;
      categoryValue = found ?? category;
      print('Filtering by found category: $category -> $categoryValue');
    }
    
    if (categoryValue == null || category.isEmpty || category == 'Tất cả') {
      // Show all foods
      print('Showing all foods (${_foods.length} items)');
      _filteredFoods.clear();
      _filteredFoods.addAll(_foods);
    } else {
      final filtered = _foods.where((food) => food.category == categoryValue).toList();
      print('Filtered foods by category "$categoryValue": ${filtered.length} items');
      _filteredFoods.clear();
      _filteredFoods.addAll(filtered);
    }
    update(); // Trigger rebuild
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
      update(); // Trigger rebuild
      return;
    }

    _isLoading.value = true;
    update(); // Trigger rebuild to show loading

    try {
      final foods = await _foodRepository.searchFoods(query);
      _filteredFoods.clear();
      _filteredFoods.addAll(foods);
      print('Search results: ${foods.length} items for query "$query"');
    } catch (e) {
      print('Error searching foods: $e');
    } finally {
      _isLoading.value = false;
      update(); // Trigger rebuild
    }
  }

  void clearFilters() {
    _filteredFoods.clear();
    _filteredFoods.addAll(_foods);
  }
}
