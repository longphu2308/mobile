import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/models/cart_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'carts';

  // Lấy cart của user
  Future<CartModel?> getUserCart(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return CartModel.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      print('Error getting cart: $e');
      return null;
    }
  }

  // Thêm item vào cart
  Future<bool> addItemToCart(
    String userId,
    String restaurantId,
    String restaurantName,
    CartItemModel item,
  ) async {
    try {
      final cartDoc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      if (!cartDoc.exists) {
        // Tạo cart mới
        final newCart = CartModel(
          userId: userId,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          items: [item],
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection(_collection)
            .doc(userId)
            .set(newCart.toMap());
      } else {
        // Cập nhật cart hiện tại
        final cart = CartModel.fromMap(cartDoc.data()!, userId);

        // Kiểm tra nếu cart từ restaurant khác -> xóa cart cũ
        if (cart.restaurantId != restaurantId) {
          final newCart = CartModel(
            userId: userId,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            items: [item],
            updatedAt: DateTime.now(),
          );
          await _firestore
              .collection(_collection)
              .doc(userId)
              .set(newCart.toMap());
        } else {
          // Kiểm tra xem item đã có trong cart chưa
          final existingIndex = cart.items.indexWhere(
            (i) => i.foodId == item.foodId,
          );

          if (existingIndex >= 0) {
            // Cập nhật quantity
            cart.items[existingIndex] = CartItemModel(
              foodId: item.foodId,
              foodName: item.foodName,
              price: item.price,
              imageUrl: item.imageUrl,
              quantity: cart.items[existingIndex].quantity + item.quantity,
            );
          } else {
            // Thêm item mới
            cart.items.add(item);
          }

          await _firestore
              .collection(_collection)
              .doc(userId)
              .update(cart.toMap());
        }
      }

      return true;
    } catch (e) {
      print('Error adding item to cart: $e');
      return false;
    }
  }

  // Cập nhật quantity của item
  Future<bool> updateItemQuantity(
    String userId,
    String foodId,
    int quantity,
  ) async {
    try {
      final cartDoc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();
      if (!cartDoc.exists) return false;

      final cart = CartModel.fromMap(cartDoc.data()!, userId);
      final itemIndex = cart.items.indexWhere((i) => i.foodId == foodId);

      if (itemIndex >= 0) {
        if (quantity <= 0) {
          // Xóa item nếu quantity <= 0
          cart.items.removeAt(itemIndex);
        } else {
          // Cập nhật quantity
          cart.items[itemIndex] = CartItemModel(
            foodId: cart.items[itemIndex].foodId,
            foodName: cart.items[itemIndex].foodName,
            price: cart.items[itemIndex].price,
            imageUrl: cart.items[itemIndex].imageUrl,
            quantity: quantity,
          );
        }

        await _firestore
            .collection(_collection)
            .doc(userId)
            .update(cart.toMap());
        return true;
      }

      return false;
    } catch (e) {
      print('Error updating item quantity: $e');
      return false;
    }
  }

  // Xóa item khỏi cart
  Future<bool> removeItemFromCart(String userId, String foodId) async {
    try {
      final cartDoc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();
      if (!cartDoc.exists) return false;

      final cart = CartModel.fromMap(cartDoc.data()!, userId);
      cart.items.removeWhere((item) => item.foodId == foodId);

      await _firestore.collection(_collection).doc(userId).update(cart.toMap());
      return true;
    } catch (e) {
      print('Error removing item from cart: $e');
      return false;
    }
  }

  // Xóa toàn bộ cart
  Future<bool> clearCart(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // Stream để lắng nghe thay đổi của cart
  Stream<CartModel?> cartStream(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        return CartModel.fromMap(snapshot.data()!, userId);
      }
      return null;
    });
  }
}
