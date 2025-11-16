import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/order_controller.dart';
import 'package:mobile/core/services/food/food_service.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => FoodService()),

    ChangeNotifierProxyProvider<AuthController, CartController>(
      create: (_) => CartController(),
      update: (_, auth, cart) => cart ?? CartController(authController: auth),
    ),

    ChangeNotifierProxyProvider<AuthController, OrderController>(
      create: (_) => OrderController(),
      update: (_, auth, order) =>
          order ?? OrderController(authController: auth),
    ),
  ];
}
