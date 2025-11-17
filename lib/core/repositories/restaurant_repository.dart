import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/models/restaurant_model.dart';

class RestaurantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'restaurants';

  // Lấy thông tin quán theo ID
  Future<RestaurantModel?> getRestaurantById(String restaurantId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(restaurantId)
          .get();
      if (doc.exists) {
        return RestaurantModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // Lấy quán của owner
  Future<RestaurantModel?> getRestaurantByOwnerId(String ownerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return RestaurantModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting restaurant by owner: $e');
      return null;
    }
  }

  // Lấy tất cả quán
  Future<List<RestaurantModel>> getAllRestaurants() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all restaurants: $e');
      return [];
    }
  }

  // Lấy các quán đang mở
  Future<List<RestaurantModel>> getOpenRestaurants() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'open')
          .get();
      return snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting open restaurants: $e');
      return [];
    }
  }

  // Tạo quán mới
  Future<String?> createRestaurant(RestaurantModel restaurant) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(restaurant.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating restaurant: $e');
      return null;
    }
  }

  // Cập nhật thông tin quán
  Future<bool> updateRestaurant(
    String restaurantId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(_collection).doc(restaurantId).update(data);
      return true;
    } catch (e) {
      print('Error updating restaurant: $e');
      return false;
    }
  }

  // Cập nhật trạng thái quán (open/closed)
  Future<bool> updateRestaurantStatus(
    String restaurantId,
    String status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(restaurantId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating restaurant status: $e');
      return false;
    }
  }

  // Xóa quán
  Future<bool> deleteRestaurant(String restaurantId) async {
    try {
      await _firestore.collection(_collection).doc(restaurantId).delete();
      return true;
    } catch (e) {
      print('Error deleting restaurant: $e');
      return false;
    }
  }

  // Stream để lắng nghe thay đổi của quán
  Stream<RestaurantModel?> restaurantStream(String restaurantId) {
    return _firestore.collection(_collection).doc(restaurantId).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          return RestaurantModel.fromMap(snapshot.data()!, snapshot.id);
        }
        return null;
      },
    );
  }
}
