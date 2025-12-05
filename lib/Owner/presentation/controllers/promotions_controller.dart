import 'package:flutter/material.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';
import 'package:mobile/core/repositories/promo_repository.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/models/promo_model.dart';

class PromotionsController extends ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final PromoRepository _promoRepository = PromoRepository();
  final _supabase = SupabaseService();

  RestaurantModel? _restaurant;
  List<PromoModel> _promos = [];
  bool _isLoading = false;
  String? _error;

  List<PromoModel> get promos => _promos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load promos của restaurant
  Future<void> loadPromos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) {
        _error = 'User not authenticated';
        return;
      }

      // Lấy restaurant của owner
      _restaurant = await _restaurantRepository.getRestaurantByOwnerId(userId);

      if (_restaurant == null) {
        _error = 'Restaurant not found';
        return;
      }

      // Lấy tất cả promos của restaurant
      _promos = await _promoRepository.getRestaurantPromos(_restaurant!.id);
    } catch (e) {
      _error = 'Error loading promos: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleActive(String promoId, bool currentActive) async {
    try {
      final success = await _promoRepository.updatePromo(
        promoId,
        {'active': !currentActive},
      );

      if (success) {
        final index = _promos.indexWhere((p) => p.id == promoId);
        if (index >= 0) {
          _promos[index] = _promos[index].copyWith(active: !currentActive);
          notifyListeners();
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
        notifyListeners();
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
        notifyListeners();
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
          notifyListeners();
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
