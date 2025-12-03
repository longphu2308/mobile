import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/models/food_model.dart';

class FoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'foods';

  // Lấy tất cả món ăn
  Future<List<FoodModel>> getAllFoods() async {
    try {
      print('FoodRepository: Fetching foods from Firestore...');
      final snapshot = await _firestore.collection(_collection).get();
      print('FoodRepository: Received ${snapshot.docs.length} documents');

      final foods = snapshot.docs.map((doc) {
        print('  - Food ID: ${doc.id}, Name: ${doc.data()['name']}');
        return FoodModel.fromMap(doc.data(), doc.id);
      }).toList();

      print('FoodRepository: Converted to ${foods.length} FoodModel objects');
      return foods;
    } catch (e) {
      print('Error getting all foods: $e');
      return [];
    }
  }

  // Lấy món ăn theo restaurant
  Future<List<FoodModel>> getFoodsByRestaurant(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snapshot.docs
          .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting foods by restaurant: $e');
      return [];
    }
  }

  // Lấy món ăn theo category
  Future<List<FoodModel>> getFoodsByCategory(
    String restaurantId,
    String category,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting foods by category: $e');
      return [];
    }
  }

  // Lấy món ăn còn hàng
  Future<List<FoodModel>> getAvailableFoods(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('available', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting available foods: $e');
      return [];
    }
  }

  // Lấy món ăn theo ID
  Future<FoodModel?> getFoodById(String foodId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(foodId).get();
      if (doc.exists) {
        return FoodModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting food: $e');
      return null;
    }
  }

  // Tìm kiếm món ăn theo tên
  Future<List<FoodModel>> searchFoods(
    String query, {
    String? restaurantId,
  }) async {
    try {
      Query queryRef = _firestore.collection(_collection);

      if (restaurantId != null) {
        queryRef = queryRef.where('restaurantId', isEqualTo: restaurantId);
      }

      final snapshot = await queryRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                FoodModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Error searching foods: $e');
      return [];
    }
  }

  // Tạo món ăn mới
  Future<String?> createFood(FoodModel food) async {
    try {
      final docRef = await _firestore.collection(_collection).add(food.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating food: $e');
      return null;
    }
  }

  // Cập nhật món ăn
  Future<bool> updateFood(String foodId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(foodId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating food: $e');
      return false;
    }
  }

  // Cập nhật trạng thái available
  Future<bool> updateFoodAvailability(String foodId, bool available) async {
    try {
      await _firestore.collection(_collection).doc(foodId).update({
        'available': available,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating food availability: $e');
      return false;
    }
  }

  // Xóa món ăn
  Future<bool> deleteFood(String foodId) async {
    try {
      await _firestore.collection(_collection).doc(foodId).delete();
      return true;
    } catch (e) {
      print('Error deleting food: $e');
      return false;
    }
  }

  // Stream để lắng nghe thay đổi món ăn của quán
  Stream<List<FoodModel>> foodsStream(String restaurantId) {
    return _firestore
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
