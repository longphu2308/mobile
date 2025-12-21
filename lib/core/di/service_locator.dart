import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/order_controller.dart';
import 'package:mobile/User/presentation/controllers/user_controller.dart';
import 'package:mobile/User/presentation/controllers/favorite_controller.dart';
import 'package:mobile/core/services/food/food_service.dart';
import 'package:mobile/Owner/presentation/controllers/restaurant_controller.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => FoodService()),
    ChangeNotifierProvider(create: (_) => UserController()),
    ChangeNotifierProvider(create: (_) => FavoriteController()),
    ChangeNotifierProvider(
      create: (_) => RestaurantController(
        repository: RestaurantRepository(),
      ),
    ),

    ChangeNotifierProxyProvider<AuthController, CartController>(
      create: (context) {
        final auth = Provider.of<AuthController>(context, listen: false);
        return CartController(authController: auth);
      },
      update: (_, auth, cart) {
        return cart ?? CartController(authController: auth);
      },
    ),

    ChangeNotifierProxyProvider<AuthController, OrderController>(
      create: (context) {
        final auth = Provider.of<AuthController>(context, listen: false);
        return OrderController(authController: auth);
      },
      update: (_, auth, order) {
        return order ?? OrderController(authController: auth);
      },
    ),
  ];
}
