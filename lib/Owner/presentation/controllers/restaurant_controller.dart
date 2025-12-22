import 'package:get/get.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';

class RestaurantController extends GetxController {
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
    // Prevent multiple simultaneous loads
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    update();

    try {
      _restaurant = await _repository.getRestaurantById(restaurantId);
      _error = null;
    } catch (e) {
      print('Error loading restaurant: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // Load restaurant by owner ID
  Future<void> loadRestaurantByOwnerId(
    String ownerId, {
    bool force = false,
  }) async {
    // Prevent multiple simultaneous loads unless forced
    if (_isLoading && !force) {
      print('Already loading restaurant, skipping...');
      return;
    }

    _isLoading = true;
    _error = null;
    update();

    try {
      print('Loading restaurant for owner: $ownerId');
      _restaurant = await _repository.getRestaurantByOwnerId(ownerId);
      _error = null;
      print('Restaurant loaded successfully: ${_restaurant?.name}');
    } catch (e) {
      print('Error loading restaurant by owner: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // Update restaurant
  Future<bool> updateRestaurant(RestaurantModel restaurant) async {
    _isLoading = true;
    _error = null;
    update();

    try {
      print('🔄 Updating restaurant: ${restaurant.name} (${restaurant.id})');
      print('📋 Update data: ${restaurant.toMap()}');

      final success = await _repository.updateRestaurant(
        restaurant.id,
        restaurant.toMap(),
      );

      if (!success) {
        throw Exception('Update returned false');
      }

      // Reload from server to ensure sync
      print('🔄 Reloading restaurant from server...');
      _restaurant = await _repository.getRestaurantById(restaurant.id);

      if (_restaurant == null) {
        throw Exception('Failed to reload restaurant after update');
      }

      print('✅ Restaurant updated and reloaded: ${_restaurant!.name}');
      _error = null;
      _isLoading = false;
      update(); // Update UI with new data
      return true;
    } catch (e, stackTrace) {
      print('❌ Error updating restaurant: $e');
      print('Stack trace: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      update();
      return false;
    }
  }

  // Update restaurant image
  Future<bool> updateImage(String restaurantId, String imageUrl) async {
    try {
      await _repository.updateRestaurant(restaurantId, {
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (_restaurant != null) {
        _restaurant = _restaurant!.copyWith(imageUrl: imageUrl);
        update();
      }
      return true;
    } catch (e) {
      print('Error updating image: $e');
      _error = e.toString();
      return false;
    }
  }
}
