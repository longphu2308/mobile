import 'package:get/get.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/promo_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/models/promo_model.dart';

class PromotionsController extends GetxController {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final PromoRepository _promoRepository = PromoRepository();
  final _supabase = SupabaseService();

  final Rx<RestaurantModel?> _restaurant = Rx<RestaurantModel?>(null);
  final RxList<PromoModel> _promos = <PromoModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString(null);

  List<PromoModel> get promos => _promos;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  // Load promos của restaurant
  Future<void> loadPromos() async {
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

      // Lấy tất cả promos của restaurant
      _promos.assignAll(
        await _promoRepository.getRestaurantPromos(_restaurant.value!.id),
      );
    } catch (e) {
      _error.value = 'Error loading promos: $e';
      print(_error.value);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleActive(String promoId, bool currentActive) async {
    try {
      final success = await _promoRepository.updatePromo(promoId, {
        'active': !currentActive,
      });

      if (success) {
        final index = _promos.indexWhere((p) => p.id == promoId);
        if (index >= 0) {
          _promos[index] = _promos[index].copyWith(active: !currentActive);
        }
      }
    } catch (e) {
      print('Error toggling promo active: $e');
    }
  }

  Future<void> deletePromo(String promoId) async {
    try {
      final success = await _promoRepository.deletePromo(promoId);

      if (success) {
        _promos.removeWhere((p) => p.id == promoId);
      }
    } catch (e) {
      print('Error deleting promo: $e');
    }
  }

  Future<void> addPromo(PromoModel promo) async {
    try {
      final promoId = await _promoRepository.createPromo(promo);

      if (promoId != null) {
        _promos.add(promo.copyWith(id: promoId));
      }
    } catch (e) {
      print('Error adding promo: $e');
    }
  }

  Future<void> updatePromo(String promoId, PromoModel updatedPromo) async {
    try {
      final success = await _promoRepository.updatePromo(
        promoId,
        updatedPromo.toMap(),
      );

      if (success) {
        final index = _promos.indexWhere((p) => p.id == promoId);
        if (index >= 0) {
          _promos[index] = updatedPromo.copyWith(id: promoId);
        }
      }
    } catch (e) {
      print('Error updating promo: $e');
    }
  }

  Future<void> refresh() async {
    await loadPromos();
  }
}
