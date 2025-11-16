import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/User/domain/models/cart_item.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get cart items for a user
  Future<List<CartItem>> getCartItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();

      return snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to load cart items: $e');
    }
  }

  /// Add item to cart
  Future<void> addItemToCart(String userId, CartItem item) async {
    try {
      final cartRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items');
      final existingItems = await cartRef
          .where('food.id', isEqualTo: item.food.id)
          .get();

      if (existingItems.docs.isNotEmpty) {
        // Update quantity
        final docId = existingItems.docs.first.id;
        final existingItem = CartItem.fromMap(existingItems.docs.first.data());
        final newQuantity = existingItem.quantity + item.quantity;
        await cartRef.doc(docId).update({'quantity': newQuantity});
      } else {
        // Add new item
        await cartRef.add(item.toMap());
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  /// Remove cart item
  Future<void> removeCartItem(String userId, String foodId) async {
    try {
      final cartRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items');
      final snapshot = await cartRef.where('food.id', isEqualTo: foodId).get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to remove cart item: $e');
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItem(
    String userId,
    String foodId,
    int quantity,
  ) async {
    try {
      final cartRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items');
      final snapshot = await cartRef.where('food.id', isEqualTo: foodId).get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'quantity': quantity});
      }
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  /// Clear cart
  Future<void> clearCart(String userId) async {
    try {
      final cartRef = _firestore
          .collection('carts')
          .doc(userId)
          .collection('items');
      final snapshot = await cartRef.get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}
