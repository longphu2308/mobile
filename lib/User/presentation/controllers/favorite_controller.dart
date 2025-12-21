import 'package:get/get.dart';
import 'package:mobile/core/repositories/favorite_repository.dart';
import 'package:mobile/core/models/favorite_model.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/errors/app_exception.dart';

enum FavoriteState { initial, loading, success, error }

class FavoriteController extends GetxController {
  final FavoriteRepository _favoriteRepository;

  final RxList<FavoriteModel> _favoriteFoods = <FavoriteModel>[].obs;
  final Rx<FavoriteState> _state = FavoriteState.initial.obs;
  final RxnString _errorMessage = RxnString(null);
  final RxBool _isLoading = false.obs;
  String? _currentUserId;

  // Getters
  List<FavoriteModel> get favoriteFoods => _favoriteFoods;
  FavoriteState get state => _state.value;
  String? get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;

  FavoriteController({FavoriteRepository? favoriteRepository})
    : _favoriteRepository = favoriteRepository ?? FavoriteRepository();

  /// Set current user ID
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  /// Load user's favorite foods
  Future<bool> loadFavorites() async {
    if (_currentUserId == null) {
      _errorMessage.value = 'User not logged in';
      _state.value = FavoriteState.error;
      return false;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final favorites = await _favoriteRepository.getUserFavorites(
        _currentUserId!,
      );
      _favoriteFoods.assignAll(
        favorites
            .where(
              (favorite) =>
                  favorite.foodId.isNotEmpty && favorite.foodName.isNotEmpty,
            )
            .toList(),
      );

      _state.value = FavoriteState.success;
      _isLoading.value = false;
      return true;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = FavoriteState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Add food to favorites
  Future<bool> addFavorite(FoodModel food) async {
    if (_currentUserId == null) {
      _errorMessage.value = 'User not logged in';
      return false;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final success = await _favoriteRepository.addFavorite(
        _currentUserId!,
        food,
      );

      if (success) {
        // Reload favorites
        await loadFavorites();
      }

      _isLoading.value = false;
      return success;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _isLoading.value = false;
      return false;
    }
  }

  /// Remove food from favorites
  Future<bool> removeFavorite(String foodId) async {
    if (_currentUserId == null) {
      _errorMessage.value = 'User not logged in';
      return false;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final success = await _favoriteRepository.removeFavorite(
        _currentUserId!,
        foodId,
      );

      if (success) {
        // Reload favorites
        await loadFavorites();
      }

      _isLoading.value = false;
      return success;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _isLoading.value = false;
      return false;
    }
  }

  /// Check if food is favorited
  Future<bool> isFavorited(String foodId) async {
    if (_currentUserId == null) return false;

    try {
      return await _favoriteRepository.isFavorited(_currentUserId!, foodId);
    } catch (e) {
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage.value = null;
  }

  /// Reset controller
  void reset() {
    _favoriteFoods.clear();
    _state.value = FavoriteState.initial;
    _errorMessage.value = null;
    _isLoading.value = false;
  }
}
