import 'package:get/get.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';

class RestaurantController extends GetxController {
  final RestaurantRepository _repository;

  final Rx<RestaurantModel?> _restaurant = Rx<RestaurantModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString(null);

  RestaurantController({required RestaurantRepository repository})
    : _repository = repository;

  // Getters
  RestaurantModel? get restaurant => _restaurant.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  // Load restaurant info
  Future<void> loadRestaurant(String restaurantId) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      _restaurant.value = await _repository.getRestaurantById(restaurantId);
      _error.value = null;
    } catch (e) {
      print('Error loading restaurant: $e');
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  // Load restaurant by owner ID
  Future<void> loadRestaurantByOwnerId(String ownerId) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      _restaurant.value = await _repository.getRestaurantByOwnerId(ownerId);
      _error.value = null;
    } catch (e) {
      print('Error loading restaurant by owner: $e');
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  // Update restaurant
  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      await _repository.updateRestaurant(restaurant.id, restaurant.toMap());
      _restaurant.value = restaurant;
      _error.value = null;
    } catch (e) {
      print('Error updating restaurant: $e');
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  // Update restaurant phone
  Future<void> updatePhone(String restaurantId, String phone) async {
    try {
      await _repository.updateRestaurant(restaurantId, {'phone': phone});
      if (_restaurant.value != null) {
        _restaurant.value = _restaurant.value!.copyWith(phone: phone);
      }
    } catch (e) {
      print('Error updating phone: $e');
      _error.value = e.toString();
    }
  }
}
