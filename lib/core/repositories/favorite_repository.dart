import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/firebase/firebase_service.dart';
import 'package:mobile/core/models/favorite_model.dart';
import 'package:mobile/core/models/restaurant_model.dart';

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

  /// Get favorite restaurants with full restaurant data
  Future<List<RestaurantModel>> getFavoriteRestaurants(String userId) async {
    try {
      // Get favorites
      final favorites = await getUserFavorites(userId);
      if (favorites.isEmpty) return [];

      // Get restaurant IDs
      final restaurantIds = favorites.map((f) => f.restaurantId).toList();

      // Get restaurants
      final restaurants = <RestaurantModel>[];
      for (final restaurantId in restaurantIds) {
        final restaurantDoc = await _firebaseService.firestore
            .collection('restaurants')
            .doc(restaurantId)
            .get();
        if (restaurantDoc.exists) {
          restaurants.add(RestaurantModel.fromMap(
              restaurantDoc.data()!, restaurantDoc.id));
        }
      }

      return restaurants;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy danh sách nhà hàng yêu thích: ${e.toString()}',
        code: 'get_favorite_restaurants_error',
      );
    }
  }

  /// Add restaurant to favorites
  Future<bool> addFavorite(String userId, String restaurantId) async {
    try {
      // Check if already favorited
      final existing = await _firebaseService.firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('restaurantId', isEqualTo: restaurantId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return false; // Already favorited
      }

      // Get restaurant info
      final restaurantDoc = await _firebaseService.firestore
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      Map<String, dynamic> favoriteData = {
        'userId': userId,
        'restaurantId': restaurantId,
        'createdAt': DateTime.now(),
      };

      if (restaurantDoc.exists) {
        final restaurantData = restaurantDoc.data()!;
        favoriteData['restaurantName'] = restaurantData['name'];
        favoriteData['restaurantImageUrl'] = restaurantData['imageUrl'];
      }

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

  /// Remove restaurant from favorites
  Future<bool> removeFavorite(String userId, String restaurantId) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('restaurantId', isEqualTo: restaurantId)
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

  /// Check if restaurant is favorited
  Future<bool> isFavorited(String userId, String restaurantId) async {
    try {
      final snapshot = await _firebaseService.firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('restaurantId', isEqualTo: restaurantId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}


