import 'package:mobile/core/models/cart_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class CartRepository {
  final _supabase = SupabaseService().client;
  final String _table = 'carts';

  // Lấy cart của user
  Future<CartModel?> getUserCart(String userId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data != null) {
        return CartModel.fromMap(data, userId);
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
      final cart = await getUserCart(userId);

      if (cart == null) {
        // Tạo cart mới
        final newCart = CartModel(
          userId: userId,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          items: [item],
          updatedAt: DateTime.now(),
        );
        await _supabase
            .from(_table)
            .insert({
              'user_id': userId,
              ...newCart.toMap(),
            });
      } else {
        // Kiểm tra nếu cart từ restaurant khác -> xóa cart cũ
        if (cart.restaurantId != restaurantId) {
          final newCart = CartModel(
            userId: userId,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            items: [item],
            updatedAt: DateTime.now(),
          );
          await _supabase
              .from(_table)
              .update(newCart.toMap())
              .eq('user_id', userId);
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

          await _supabase
              .from(_table)
              .update(cart.toMap())
              .eq('user_id', userId);
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
      final cart = await getUserCart(userId);
      if (cart == null) return false;

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

        await _supabase
            .from(_table)
            .update(cart.toMap())
            .eq('user_id', userId);
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
      final cart = await getUserCart(userId);
      if (cart == null) return false;

      cart.items.removeWhere((item) => item.foodId == foodId);

      await _supabase
          .from(_table)
          .update(cart.toMap())
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error removing item from cart: $e');
      return false;
    }
  }

  // Xóa toàn bộ cart
  Future<bool> clearCart(String userId) async {
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // Stream để lắng nghe thay đổi của cart
  Stream<CartModel?> cartStream(String userId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) {
          if (data.isNotEmpty) {
            return CartModel.fromMap(data.first, userId);
          }
          return null;
        });
  }
}
