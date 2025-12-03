import 'package:flutter/foundation.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/repositories/cart_repository.dart';
import 'package:mobile/core/models/cart_model.dart';
import 'package:mobile/core/models/food_model.dart';

class CartController extends ChangeNotifier {
  final CartRepository _cartRepository;
  final AuthController? _authController;
  final List<CartItemModel> _items = [];
  String? _currentUserId;
  String? _currentRestaurantId;
  String? _currentRestaurantName;

  CartController({
    CartRepository? cartRepository,
    AuthController? authController,
  }) : _cartRepository = cartRepository ?? CartRepository(),
       _authController = authController {
    _init();
  }

  List<CartItemModel> get items => List.unmodifiable(_items);
  String? get currentRestaurantId => _currentRestaurantId;
  String? get currentRestaurantName => _currentRestaurantName;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _init() {
    _authController?.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    final userId = _authController?.currentUser?.userId;
    if (userId != null && userId != _currentUserId) {
      _currentUserId = userId;
      loadCartFromFirebase();
    } else if (userId == null) {
      _currentUserId = null;
      _items.clear();
      notifyListeners();
    }
  }

  Future<void> loadCartFromFirebase() async {
    if (_currentUserId == null) return;

    try {
      final cart = await _cartRepository.getUserCart(_currentUserId!);
      _items.clear();
      if (cart != null) {
        _items.addAll(cart.items);
        _currentRestaurantId = cart.restaurantId;
        _currentRestaurantName = cart.restaurantName;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  void addItem(
    FoodModel food, {
    String restaurantId = '',
    String restaurantName = '',
  }) {
    final existingIndex = _items.indexWhere((item) => item.foodId == food.id);

    if (existingIndex >= 0) {
      final newQuantity = _items[existingIndex].quantity + 1;
      _items[existingIndex] = CartItemModel(
        foodId: food.id,
        foodName: food.name,
        price: food.price,
        imageUrl: food.imageUrl,
        quantity: newQuantity,
      );
    } else {
      _items.add(
        CartItemModel(
          foodId: food.id,
          foodName: food.name,
          price: food.price,
          imageUrl: food.imageUrl,
          quantity: 1,
        ),
      );
    }

    if (_currentRestaurantId == null || _currentRestaurantId != restaurantId) {
      _currentRestaurantId = restaurantId;
      _currentRestaurantName = restaurantName;
    }

    if (_currentUserId != null) {
      _cartRepository
          .addItemToCart(
            _currentUserId!,
            restaurantId,
            restaurantName,
            _items.last,
          )
          .catchError((e) {
            print('Error syncing cart: $e');
            return false;
          });
    }

    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.removeWhere((item) => item.foodId == foodId);

    if (_currentUserId != null) {
      _cartRepository.removeItemFromCart(_currentUserId!, foodId).catchError((
        e,
      ) {
        print('Error syncing cart: $e');
        return false;
      });
    }

    notifyListeners();
  }

  void updateQuantity(String foodId, int quantity) {
    if (quantity <= 0) {
      removeItem(foodId);
      return;
    }

    final index = _items.indexWhere((item) => item.foodId == foodId);
    if (index >= 0) {
      _items[index] = CartItemModel(
        foodId: _items[index].foodId,
        foodName: _items[index].foodName,
        price: _items[index].price,
        imageUrl: _items[index].imageUrl,
        quantity: quantity,
      );

      if (_currentUserId != null) {
        _cartRepository
            .updateItemQuantity(_currentUserId!, foodId, quantity)
            .catchError((e) {
              print('Error syncing cart: $e');
              return false;
            });
      }

      notifyListeners();
    }
  }

  void incrementQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.foodId == foodId);
    if (index >= 0) {
      updateQuantity(foodId, _items[index].quantity + 1);
    }
  }

  void decrementQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.foodId == foodId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        updateQuantity(foodId, _items[index].quantity - 1);
      } else {
        removeItem(foodId);
      }
    }
  }

  void clear() {
    _items.clear();

    if (_currentUserId != null) {
      _cartRepository.clearCart(_currentUserId!).catchError((e) {
        print('Error clearing cart: $e');
        return false;
      });
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _authController?.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
