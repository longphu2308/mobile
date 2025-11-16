import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/User/domain/models/food.dart';
import 'package:mobile/core/services/firebase/firebase_service.dart';

class FoodRepository {
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  // Get all foods from Firebase
  Future<List<Food>> getAllFoods() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('foods').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Food.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting foods: $e');
      return [];
    }
  }

  // Get foods by category
  Future<List<Food>> getFoodsByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('foods')
          .where('foodCategory', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Food.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting foods by category: $e');
      return [];
    }
  }

  // Search foods by name
  Future<List<Food>> searchFoods(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('foods')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Food.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error searching foods: $e');
      return [];
    }
  }
}
