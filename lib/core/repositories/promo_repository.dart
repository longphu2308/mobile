import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/models/promo_model.dart';

class PromoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'promos';

  // Lấy tất cả promos
  Future<List<PromoModel>> getAllPromos() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => PromoModel.fromMap(doc.data(), doc.id))
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
      Query query = _firestore
          .collection(_collection)
          .where('active', isEqualTo: true);

      if (type != null) {
        query = query.where('type', whereIn: [type, 'both']);
      }

      if (restaurantId != null) {
        query = query.where('restaurantId', isEqualTo: restaurantId);
      }

      final snapshot = await query.get();
      final now = DateTime.now();

      return snapshot.docs
          .map(
            (doc) =>
                PromoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .where(
            (promo) =>
                now.isAfter(promo.startDate) && now.isBefore(promo.endDate),
          )
          .toList();
    } catch (e) {
      print('Error getting active promos: $e');
      return [];
    }
  }

  // Lấy promos của restaurant (cho owner)
  Future<List<PromoModel>> getRestaurantPromos(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snapshot.docs
          .map((doc) => PromoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting restaurant promos: $e');
      return [];
    }
  }

  // Lấy promo theo code
  Future<PromoModel?> getPromoByCode(String code) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PromoModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
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
      final doc = await _firestore.collection(_collection).doc(promoId).get();
      if (doc.exists) {
        return PromoModel.fromMap(doc.data()!, doc.id);
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
      final docRef = await _firestore
          .collection(_collection)
          .add(promo.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating promo: $e');
      return null;
    }
  }

  // Cập nhật promo
  Future<bool> updatePromo(String promoId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(promoId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating promo: $e');
      return false;
    }
  }

  // Toggle active status
  Future<bool> togglePromoActive(String promoId, bool active) async {
    try {
      await _firestore.collection(_collection).doc(promoId).update({
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error toggling promo active: $e');
      return false;
    }
  }

  // Tăng used count khi user sử dụng promo
  Future<bool> incrementUsedCount(String promoId) async {
    try {
      await _firestore.collection(_collection).doc(promoId).update({
        'usedCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error incrementing used count: $e');
      return false;
    }
  }

  // Xóa promo
  Future<bool> deletePromo(String promoId) async {
    try {
      await _firestore.collection(_collection).doc(promoId).delete();
      return true;
    } catch (e) {
      print('Error deleting promo: $e');
      return false;
    }
  }

  // Stream để lắng nghe promos của restaurant
  Stream<List<PromoModel>> restaurantPromosStream(String restaurantId) {
    return _firestore
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PromoModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
