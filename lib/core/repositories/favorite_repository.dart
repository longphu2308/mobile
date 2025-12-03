import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/firebase/firebase_service.dart';
import 'package:mobile/core/models/favorite_model.dart';
import 'package:mobile/core/models/food_model.dart';

class FavoriteRepository {
  final FirebaseService _firebaseService;

  FavoriteRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  /// Get all favorites for a user
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseService
          .firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final favorites = snapshot.docs
          .map((doc) => FavoriteModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort by createdAt descending in memory to avoid needing composite index
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return favorites;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy danh sách yêu thích: ${e.toString()}',
        code: 'get_favorites_error',
      );
    }
  }

  /// Add food to favorites
  Future<bool> addFavorite(String userId, FoodModel food) async {
    try {
      // Check if already favorited
      final existing = await _firebaseService.firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('foodId', isEqualTo: food.id)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return false; // Already favorited
      }

      final favoriteData = {
        'userId': userId,
        'foodId': food.id,
        'foodName': food.name,
        'foodImageUrl': food.imageUrl,
        'price': food.price,
        'restaurantId': food.restaurantId,
        'createdAt': DateTime.now(),
      };

      await _firebaseService.firestore
          .collection('favorites')
          .add(favoriteData);

      return true;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi thêm vào yêu thích: ${e.toString()}',
        code: 'add_favorite_error',
      );
    }
  }

  /// Remove food from favorites
  Future<bool> removeFavorite(String userId, String foodId) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('foodId', isEqualTo: foodId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      await _firebaseService.firestore
          .collection('favorites')
          .doc(snapshot.docs.first.id)
          .delete();

      return true;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi xóa khỏi yêu thích: ${e.toString()}',
        code: 'remove_favorite_error',
      );
    }
  }

  /// Check if food is favorited
  Future<bool> isFavorited(String userId, String foodId) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('foodId', isEqualTo: foodId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}


