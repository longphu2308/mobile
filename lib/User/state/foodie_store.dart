import 'package:flutter/foundation.dart';
import 'package:mobile/User/models/food.dart';

enum DeliveryMethod { door, pickup }

enum PaymentMethod { cash, bank }

class FoodieUser {
  final String name;
  final String email;
  final String phone;
  final String address;

  const FoodieUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  FoodieUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    return FoodieUser(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

class CartItem {
  final Food food;
  final int quantity;

  CartItem({
    required this.food,
    this.quantity = 1,
  });

  double get subtotal => food.price * quantity;

  CartItem copyWith({
    Food? food,
    int? quantity,
  }) {
    return CartItem(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }
}

class VendorCart {
  final String vendorId;
  final String vendorName;
  final List<CartItem> items;

  VendorCart({
    required this.vendorId,
    required this.vendorName,
    List<CartItem>? items,
  }) : items = items ?? [];

  double get total =>
      items.fold(0, (double total, item) => total + item.subtotal);

  int get totalItems =>
      items.fold(0, (int total, item) => total + item.quantity);
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;
}

class FoodOrder {
  final String vendorId;
  final String vendorName;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DeliveryMethod deliveryMethod;
  final PaymentMethod paymentMethod;

  const FoodOrder({
    required this.vendorId,
    required this.vendorName,
    required this.items,
    required this.createdAt,
    required this.deliveryMethod,
    required this.paymentMethod,
  });

  double get total =>
      items.fold(0, (double total, item) => total + item.subtotal);
}

class FoodieStore extends ChangeNotifier {
  FoodieUser _user = const FoodieUser(
    name: 'Jane Doe',
    email: 'janedoe@email.com',
    phone: '+84 000 000 000',
    address: '123 Nguyen Trai, District 1, Ho Chi Minh City',
  );

  final Map<String, VendorCart> _cartByVendor = {};
  final List<Food> _favoriteFoods = [];
  final List<FoodOrder> _orders = [];

  FoodieUser get user => _user;

  List<VendorCart> get vendorCarts =>
      _cartByVendor.values.toList(growable: false);

  int get totalCartItems => vendorCarts.fold(
        0,
        (prev, cart) => prev + cart.totalItems,
      );

  double totalForVendor(String vendorId) =>
      _cartByVendor[vendorId]?.total ?? 0;

  List<Food> get favoriteFoods => List.unmodifiable(_favoriteFoods);

  List<FoodOrder> get orders => List.unmodifiable(_orders);

  bool isFavorite(Food food) =>
      _favoriteFoods.any((item) => _isSameFood(item, food));

  bool get hasItemsInCart => _cartByVendor.isNotEmpty;

  VendorCart? cartForVendor(String vendorId) => _cartByVendor[vendorId];

  void toggleFavorite(Food food) {
    final index =
        _favoriteFoods.indexWhere((item) => _isSameFood(item, food));
    if (index == -1) {
      _favoriteFoods.add(food);
    } else {
      _favoriteFoods.removeAt(index);
    }
    notifyListeners();
  }

  void addToCart(Food food) {
    final vendorId = food.vendorId;
    final cart = _cartByVendor.putIfAbsent(
      vendorId,
      () => VendorCart(
        vendorId: vendorId,
        vendorName: food.vendorName,
      ),
    );
    final index = cart.items.indexWhere((item) => _isSameFood(item.food, food));
    if (index == -1) {
      cart.items.add(CartItem(food: food));
    } else {
      final current = cart.items[index];
      cart.items[index] =
          current.copyWith(quantity: current.quantity + 1);
    }
    notifyListeners();
  }

  void decreaseQuantity(Food food) {
    final cart = _findCartContainingFood(food);
    if (cart == null) return;
    final index =
        cart.items.indexWhere((item) => _isSameFood(item.food, food));
    if (index == -1) return;
    final current = cart.items[index];
    if (current.quantity == 1) {
      cart.items.removeAt(index);
    } else {
      cart.items[index] =
          current.copyWith(quantity: current.quantity - 1);
    }
    if (cart.items.isEmpty) {
      _cartByVendor.remove(cart.vendorId);
    }
    notifyListeners();
  }

  void increaseQuantity(Food food) {
    final cart = _findCartContainingFood(food);
    if (cart == null) return;
    final index =
        cart.items.indexWhere((item) => _isSameFood(item.food, food));
    if (index == -1) return;
    final current = cart.items[index];
    cart.items[index] =
        current.copyWith(quantity: current.quantity + 1);
    notifyListeners();
  }

  void removeFromCart(Food food) {
    final cart = _findCartContainingFood(food);
    if (cart == null) return;
    cart.items.removeWhere((item) => _isSameFood(item.food, food));
    if (cart.items.isEmpty) {
      _cartByVendor.remove(cart.vendorId);
    }
    notifyListeners();
  }

  void clearVendorCart(String vendorId) {
    _cartByVendor.remove(vendorId);
    notifyListeners();
  }

  FoodOrder? placeOrderForVendor(
    String vendorId, {
    DeliveryMethod deliveryMethod = DeliveryMethod.door,
    PaymentMethod paymentMethod = PaymentMethod.cash,
  }) {
    final cart = _cartByVendor[vendorId];
    if (cart == null || cart.items.isEmpty) {
      return null;
    }
    final orderItems = cart.items
        .map(
          (item) => OrderItem(
            name: item.food.name,
            price: item.food.price,
            quantity: item.quantity,
          ),
        )
        .toList(growable: false);
    final order = FoodOrder(
      vendorId: vendorId,
      vendorName: cart.vendorName,
      items: orderItems,
      createdAt: DateTime.now(),
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
    );
    _orders.insert(0, order);
    _cartByVendor.remove(vendorId);
    notifyListeners();
    return order;
  }

  void clearHistory() {
    _orders.clear();
    notifyListeners();
  }

  void updateProfile(FoodieUser user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _cartByVendor.clear();
    _favoriteFoods.clear();
    _orders.clear();
    notifyListeners();
  }

  VendorCart? _findCartContainingFood(Food food) {
    for (final cart in _cartByVendor.values) {
      final exists = cart.items.any((item) => _isSameFood(item.food, food));
      if (exists) return cart;
    }
    return null;
  }

  bool _isSameFood(Food a, Food b) => a.name == b.name;
}
