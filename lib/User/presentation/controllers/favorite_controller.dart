import 'package:flutter/material.dart';
import 'package:mobile/core/repositories/favorite_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/errors/app_exception.dart';

enum FavoriteState { initial, loading, success, error }

class FavoriteController extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;

  List<RestaurantModel> _favoriteRestaurants = [];
  FavoriteState _state = FavoriteState.initial;
  String? _errorMessage;
  bool _isLoading = false;
  String? _currentUserId;

  // Getters
  List<RestaurantModel> get favoriteRestaurants => _favoriteRestaurants;
  FavoriteState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  FavoriteController({FavoriteRepository? favoriteRepository})
      : _favoriteRepository = favoriteRepository ?? FavoriteRepository();

  /// Set current user ID
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  /// Load user's favorite restaurants
  Future<bool> loadFavorites() async {
    if (_currentUserId == null) {
      _errorMessage = 'Người dùng chưa đăng nhập';
      _state = FavoriteState.error;
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      _favoriteRestaurants =
          await _favoriteRepository.getFavoriteRestaurants(_currentUserId!);

      _state = FavoriteState.success;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = FavoriteState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Add restaurant to favorites
  Future<bool> addFavorite(String restaurantId) async {
    if (_currentUserId == null) {
      _errorMessage = 'Người dùng chưa đăng nhập';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final success = await _favoriteRepository.addFavorite(
        _currentUserId!,
        restaurantId,
      );

      if (success) {
        // Reload favorites
        await loadFavorites();
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Remove restaurant from favorites
  Future<bool> removeFavorite(String restaurantId) async {
    if (_currentUserId == null) {
      _errorMessage = 'Người dùng chưa đăng nhập';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final success = await _favoriteRepository.removeFavorite(
        _currentUserId!,
        restaurantId,
      );

      if (success) {
        // Reload favorites
        await loadFavorites();
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Check if restaurant is favorited
  Future<bool> isFavorited(String restaurantId) async {
    if (_currentUserId == null) return false;

    try {
      return await _favoriteRepository.isFavorited(
        _currentUserId!,
        restaurantId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Private helper
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// Reset controller
  void reset() {
    _favoriteRestaurants = [];
    _state = FavoriteState.initial;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}


