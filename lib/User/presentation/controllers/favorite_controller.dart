import 'package:flutter/material.dart';
import 'package:mobile/core/repositories/favorite_repository.dart';
import 'package:mobile/core/models/favorite_model.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/core/errors/app_exception.dart';

enum FavoriteState { initial, loading, success, error }

class FavoriteController extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;

  List<FavoriteModel> _favoriteFoods = [];
  FavoriteState _state = FavoriteState.initial;
  String? _errorMessage;
  bool _isLoading = false;
  String? _currentUserId;

  // Getters
  List<FavoriteModel> get favoriteFoods => _favoriteFoods;
  FavoriteState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  FavoriteController({FavoriteRepository? favoriteRepository})
      : _favoriteRepository = favoriteRepository ?? FavoriteRepository();

  /// Set current user ID
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  /// Load user's favorite foods
  Future<bool> loadFavorites() async {
    if (_currentUserId == null) {
      _errorMessage = 'User not logged in';
      _state = FavoriteState.error;
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final favorites =
          await _favoriteRepository.getUserFavorites(_currentUserId!);
      _favoriteFoods = favorites
          .where((favorite) =>
              favorite.foodId.isNotEmpty && favorite.foodName.isNotEmpty)
          .toList();

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

  /// Add food to favorites
  Future<bool> addFavorite(FoodModel food) async {
    if (_currentUserId == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final success =
          await _favoriteRepository.addFavorite(_currentUserId!, food);

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

  /// Remove food from favorites
  Future<bool> removeFavorite(String foodId) async {
    if (_currentUserId == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final success = await _favoriteRepository.removeFavorite(
        _currentUserId!,
        foodId,
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

  /// Check if food is favorited
  Future<bool> isFavorited(String foodId) async {
    if (_currentUserId == null) return false;

    try {
      return await _favoriteRepository.isFavorited(
        _currentUserId!,
        foodId,
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
    _favoriteFoods = [];
    _state = FavoriteState.initial;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}


