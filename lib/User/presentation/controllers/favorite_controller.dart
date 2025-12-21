import 'package:get/get.dart';
import 'package:mobile/core/repositories/favorite_repository.dart';
import 'package:mobile/core/models/favorite_model.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

enum FavoriteState { initial, loading, success, error }

class FavoriteController extends GetxController {
  final FavoriteRepository _favoriteRepository;
  final SupabaseService _supabase = SupabaseService();

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

  /// Get user ID with fallback to Supabase
  String? _getUserId() {
    return _currentUserId ?? _supabase.currentUser?.id;
  }

  /// Load user's favorite foods
  Future<bool> loadFavorites() async {
    final userId = _getUserId();
    if (userId == null) {
      print('FavoriteController: Cannot load favorites - no user logged in');
      _errorMessage.value = 'User not logged in';
      _state.value = FavoriteState.error;
      return false;
    }

    // Update _currentUserId if it was null
    _currentUserId ??= userId;

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      print('FavoriteController: Loading favorites for user $userId');
      final favorites = await _favoriteRepository.getUserFavorites(userId);
      _favoriteFoods.assignAll(
        favorites
            .where(
              (favorite) =>
                  favorite.foodId.isNotEmpty && favorite.foodName.isNotEmpty,
            )
            .toList(),
      );

      _state.value = FavoriteState.success;
      print('FavoriteController: Loaded ${_favoriteFoods.length} favorites');
      return true;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = FavoriteState.error;
      print('FavoriteController: Error loading favorites - ${e.message}');
      return false;
    } catch (e) {
      _errorMessage.value = 'Lỗi tải danh sách yêu thích';
      _state.value = FavoriteState.error;
      print('FavoriteController: Error loading favorites - $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Add food to favorites
  Future<bool> addFavorite(FoodModel food) async {
    final userId = _getUserId();
    if (userId == null) {
      print('FavoriteController: Cannot add favorite - no user logged in');
      _errorMessage.value = 'User not logged in';
      return false;
    }

    // Update _currentUserId if it was null
    _currentUserId ??= userId;

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      print(
        'FavoriteController: Adding favorite ${food.name} for user $userId',
      );
      final success = await _favoriteRepository.addFavorite(userId, food);

      if (success) {
        print('FavoriteController: Successfully added favorite');
        // Reload favorites
        await loadFavorites();
      } else {
        print('FavoriteController: Food already in favorites');
      }

      _isLoading.value = false;
      return success;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _isLoading.value = false;
      print('FavoriteController: Error adding favorite - ${e.message}');
      return false;
    } catch (e) {
      _errorMessage.value = 'Lỗi thêm vào yêu thích';
      _isLoading.value = false;
      print('FavoriteController: Error adding favorite - $e');
      return false;
    }
  }

  /// Remove food from favorites
  Future<bool> removeFavorite(String foodId) async {
    final userId = _getUserId();
    if (userId == null) {
      print('FavoriteController: Cannot remove favorite - no user logged in');
      _errorMessage.value = 'User not logged in';
      return false;
    }

    // Update _currentUserId if it was null
    _currentUserId ??= userId;

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      print('FavoriteController: Removing favorite $foodId for user $userId');
      final success = await _favoriteRepository.removeFavorite(userId, foodId);

      if (success) {
        print('FavoriteController: Successfully removed favorite');
        // Reload favorites
        await loadFavorites();
      }

      _isLoading.value = false;
      return success;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _isLoading.value = false;
      print('FavoriteController: Error removing favorite - ${e.message}');
      return false;
    } catch (e) {
      _errorMessage.value = 'Lỗi xóa khỏi yêu thích';
      _isLoading.value = false;
      print('FavoriteController: Error removing favorite - $e');
      return false;
    }
  }

  /// Check if food is favorited
  Future<bool> isFavorited(String foodId) async {
    final userId = _getUserId();
    if (userId == null) return false;

    try {
      return await _favoriteRepository.isFavorited(userId, foodId);
    } catch (e) {
      print('FavoriteController: Error checking favorite status - $e');
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
