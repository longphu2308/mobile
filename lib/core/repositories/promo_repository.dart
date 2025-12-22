import 'package:mobile/core/models/promo_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class PromoRepository {
  final _supabase = SupabaseService().client;
  final String _table = 'promos';

  // Lấy tất cả promos
  Future<List<PromoModel>> getAllPromos() async {
    try {
      final data = await _supabase.from(_table).select();
      return (data as List)
          .map((item) => PromoModel.fromMap(item, item['promo_id']))
          .toList();
    } catch (e) {
      print('Error getting all promos: $e');
      return [];
    }
  }

  // Lấy promos đang active
  Future<List<PromoModel>> getActivePromos({
    String? type,
    String? restaurantId,
  }) async {
    try {
      var query = _supabase.from(_table).select().eq('active', true);

      if (type != null && restaurantId != null) {
        query = query.or('type.eq.$type,type.eq.both').eq('restaurant_id', restaurantId);
      } else if (type != null) {
        query = query.or('type.eq.$type,type.eq.both');
      } else if (restaurantId != null) {
        query = query.eq('restaurant_id', restaurantId);
      }

      final data = await query;
      final now = DateTime.now();

      return (data as List)
          .map((item) => PromoModel.fromMap(item, item['promo_id']))
          .where((promo) =>
              now.isAfter(promo.startDate) && now.isBefore(promo.endDate))
          .toList();
    } catch (e) {
      print('Error getting active promos: $e');
      return [];
    }
  }

  // Lấy promos của restaurant (cho owner)
  Future<List<PromoModel>> getRestaurantPromos(String restaurantId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('restaurant_id', restaurantId);
      return (data as List)
          .map((item) => PromoModel.fromMap(item, item['promo_id']))
          .toList();
    } catch (e) {
      print('Error getting restaurant promos: $e');
      return [];
    }
  }

  // Lấy promo theo code
  Future<PromoModel?> getPromoByCode(String code) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('code', code)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        return PromoModel.fromMap(data, data['promo_id']);
      }
      return null;
    } catch (e) {
      print('Error getting promo by code: $e');
      return null;
    }
  }

  // Lấy promo theo ID
  Future<PromoModel?> getPromoById(String promoId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('promo_id', promoId)
          .maybeSingle();
      if (data != null) {
        return PromoModel.fromMap(data, data['promo_id']);
      }
      return null;
    } catch (e) {
      print('Error getting promo: $e');
      return null;
    }
  }

  // Tạo promo mới
  Future<String?> createPromo(PromoModel promo) async {
    try {
      final data = await _supabase
          .from(_table)
          .insert(promo.toMap())
          .select()
          .single();
      return data['promo_id'];
    } catch (e) {
      print('Error creating promo: $e');
      rethrow; // Rethrow để controller có thể bắt và xử lý
    }
  }

  // Cập nhật promo
  Future<bool> updatePromo(String promoId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _supabase
          .from(_table)
          .update(data)
          .eq('promo_id', promoId);
      return true;
    } catch (e) {
      print('Error updating promo: $e');
      rethrow; // Rethrow để controller có thể bắt và xử lý
    }
  }

  // Xóa promo
  Future<bool> deletePromo(String promoId) async {
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('promo_id', promoId);
      return true;
    } catch (e) {
      print('Error deleting promo: $e');
      return false;
    }
  }

  // Tăng used_count
  Future<bool> incrementUsedCount(String promoId) async {
    try {
      final promo = await getPromoById(promoId);
      if (promo != null) {
        await updatePromo(promoId, {'used_count': promo.usedCount + 1});
      }
      return true;
    } catch (e) {
      print('Error incrementing used count: $e');
      return false;
    }
  }

  // Validate promo
  Future<bool> validatePromo(
    String code,
    String? restaurantId,
    String userType,
  ) async {
    try {
      final promo = await getPromoByCode(code);
      if (promo == null || !promo.active) return false;

      final now = DateTime.now();
      if (now.isBefore(promo.startDate) || now.isAfter(promo.endDate)) {
        return false;
      }

      // Check if promo is for specific restaurant
      if (promo.restaurantId != null &&
          promo.restaurantId != restaurantId) {
        return false;
      }

      // Check if promo is for user type
      if (promo.type != 'both' && promo.type != userType) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating promo: $e');
      return false;
    }
  }
}
