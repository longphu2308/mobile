import 'package:get/get.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/order_controller.dart';
import 'package:mobile/User/presentation/controllers/user_controller.dart';
import 'package:mobile/User/presentation/controllers/favorite_controller.dart';
import 'package:mobile/core/services/food/food_service.dart';
import 'package:mobile/Owner/presentation/controllers/restaurant_controller.dart';
import 'package:mobile/Owner/presentation/controllers/dashboard_controller.dart';
import 'package:mobile/Owner/presentation/controllers/orders_controller.dart';
import 'package:mobile/Owner/presentation/controllers/menu_controller.dart';
import 'package:mobile/Owner/presentation/controllers/promotions_controller.dart';
import 'package:mobile/Shipper/controllers/shipper_controller.dart';
import 'package:mobile/core/repositories/restaurant_repository.dart';

/// Initialize all GetX controllers
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Auth - put first as other controllers depend on it
    Get.put(AuthController(), permanent: true);

    // User controllers
    Get.put(UserController(), permanent: true);
    Get.put(FavoriteController(), permanent: true);
    Get.put(
      CartController(authController: Get.find<AuthController>()),
      permanent: true,
    );
    Get.put(
      OrderController(authController: Get.find<AuthController>()),
      permanent: true,
    );

    // Owner controllers
    Get.put(RestaurantController(repository: RestaurantRepository()), permanent: true);
    Get.put(DashboardController(), permanent: true);
    Get.put(OrdersController(), permanent: true);
    Get.put(MenuScreenController(), permanent: true);
    Get.put(PromotionsController(), permanent: true);

    // Shipper controllers
    Get.put(ShipperController(), permanent: true);

    // Services
    Get.put(FoodService(), permanent: true);
  }
}

/// Initialize controllers when app starts
void initializeControllers() {
  // Auth should always be available
  if (!Get.isRegistered<AuthController>()) {
    Get.put(AuthController(), permanent: true);
  }
}

/// Get AuthController instance
AuthController get authController => Get.find<AuthController>();

/// Get CartController instance
CartController get cartController {
  if (!Get.isRegistered<CartController>()) {
    Get.put(CartController(authController: Get.find<AuthController>()));
  }
  return Get.find<CartController>();
}

/// Get OrderController instance
OrderController get orderController {
  if (!Get.isRegistered<OrderController>()) {
    Get.put(OrderController(authController: Get.find<AuthController>()));
  }
  return Get.find<OrderController>();
}

/// Get UserController instance
UserController get userController {
  if (!Get.isRegistered<UserController>()) {
    Get.put(UserController());
  }
  return Get.find<UserController>();
}

/// Get FavoriteController instance
FavoriteController get favoriteController {
  if (!Get.isRegistered<FavoriteController>()) {
    Get.put(FavoriteController());
  }
  return Get.find<FavoriteController>();
}

/// Get DashboardController instance
DashboardController get dashboardController {
  if (!Get.isRegistered<DashboardController>()) {
    Get.put(DashboardController());
  }
  return Get.find<DashboardController>();
}

/// Get OrdersController instance (Owner)
OrdersController get ownerOrdersController {
  if (!Get.isRegistered<OrdersController>()) {
    Get.put(OrdersController());
  }
  return Get.find<OrdersController>();
}

/// Get MenuScreenController instance
MenuScreenController get menuController {
  if (!Get.isRegistered<MenuScreenController>()) {
    Get.put(MenuScreenController());
  }
  return Get.find<MenuScreenController>();
}

/// Get PromotionsController instance
PromotionsController get promotionsController {
  if (!Get.isRegistered<PromotionsController>()) {
    Get.put(PromotionsController());
  }
  return Get.find<PromotionsController>();
}

/// Get RestaurantController instance
RestaurantController get restaurantController {
  if (!Get.isRegistered<RestaurantController>()) {
    Get.put(RestaurantController(repository: RestaurantRepository()));
  }
  return Get.find<RestaurantController>();
}

/// Get ShipperController instance
ShipperController get shipperController {
  if (!Get.isRegistered<ShipperController>()) {
    Get.put(ShipperController());
  }
  return Get.find<ShipperController>();
}

/// Get FoodService instance
FoodService get foodService {
  if (!Get.isRegistered<FoodService>()) {
    Get.put(FoodService());
  }
  return Get.find<FoodService>();
}
