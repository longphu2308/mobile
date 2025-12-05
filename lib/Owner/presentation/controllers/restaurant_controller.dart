import 'package:flutter/foundation.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';

class RestaurantController extends ChangeNotifier {
  final RestaurantRepository _repository;

  RestaurantModel? _restaurant;
  bool _isLoading = false;
  String? _error;

  RestaurantController({required RestaurantRepository repository})
    : _repository = repository;

  // Getters
  RestaurantModel? get restaurant => _restaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load restaurant info
  Future<void> loadRestaurant(String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurant = await _repository.getRestaurantById(restaurantId);
      _error = null;
    } catch (e) {
      print('Error loading restaurant: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load restaurant by owner ID
  Future<void> loadRestaurantByOwnerId(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurant = await _repository.getRestaurantByOwnerId(ownerId);
      _error = null;
    } catch (e) {
      print('Error loading restaurant by owner: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update restaurant
  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateRestaurant(restaurant.id, restaurant.toMap());
      _restaurant = restaurant;
      _error = null;
    } catch (e) {
      print('Error updating restaurant: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update restaurant phone
  Future<void> updatePhone(String restaurantId, String phone) async {
    try {
      await _repository.updateRestaurant(restaurantId, {'phone': phone});
      if (_restaurant != null) {
        _restaurant = _restaurant!.copyWith(phone: phone);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating phone: $e');
      _error = e.toString();
      notifyListeners();
    }
  }
}
