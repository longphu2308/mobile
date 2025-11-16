import 'package:flutter/foundation.dart';
import 'package:mobile/User/domain/models/cart_item.dart';
import 'package:mobile/User/domain/models/food.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/User/data/repositories/cart_repository.dart';

class CartController extends ChangeNotifier {
  final CartRepository _cartRepository;
  final AuthController? _authController;
  final List<CartItem> _items = [];
  String? _currentUserId;

  CartController({
    CartRepository? cartRepository,
    AuthController? authController,
  }) : _cartRepository = cartRepository ?? CartRepository(),
       _authController = authController {
    _init();
  }

  List<CartItem> get items => List.unmodifiable(_items);

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

  /// Load cart from Firebase
  Future<void> loadCartFromFirebase() async {
    if (_currentUserId == null) return;

    try {
      final firebaseItems = await _cartRepository.getCartItems(_currentUserId!);
      _items.clear();
      _items.addAll(firebaseItems);
      notifyListeners();
    } catch (e) {
      // Handle error silently for now
      print('Error loading cart: $e');
    }
  }

  void addItem(Food food) {
    final existingIndex = _items.indexWhere((item) => item.food.id == food.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(food: food, quantity: 1));
    }

    // Sync with Firebase
    if (_currentUserId != null) {
      _cartRepository.addItemToCart(_currentUserId!, _items.last).catchError((
        e,
      ) {
        print('Error syncing cart: $e');
      });
    }

    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.removeWhere((item) => item.food.id == foodId);

    // Sync with Firebase
    if (_currentUserId != null) {
      _cartRepository.removeCartItem(_currentUserId!, foodId).catchError((e) {
        print('Error syncing cart: $e');
      });
    }

    notifyListeners();
  }

  void updateQuantity(String foodId, int quantity) {
    if (quantity <= 0) {
      removeItem(foodId);
      return;
    }

    final index = _items.indexWhere((item) => item.food.id == foodId);
    if (index >= 0) {
      _items[index].quantity = quantity;

      // Sync with Firebase
      if (_currentUserId != null) {
        _cartRepository
            .updateCartItem(_currentUserId!, foodId, quantity)
            .catchError((e) {
              print('Error syncing cart: $e');
            });
      }

      notifyListeners();
    }
  }

  void incrementQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.food.id == foodId);
    if (index >= 0) {
      updateQuantity(foodId, _items[index].quantity + 1);
    }
  }

  void decrementQuantity(String foodId) {
    final index = _items.indexWhere((item) => item.food.id == foodId);
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

    // Sync with Firebase
    if (_currentUserId != null) {
      _cartRepository.clearCart(_currentUserId!).catchError((e) {
        print('Error clearing cart: $e');
      });
    }

    notifyListeners();
  }
}
