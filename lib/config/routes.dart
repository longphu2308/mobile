import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/User/presentation/views/auth/welcome_screen.dart';
import 'package:mobile/User/presentation/views/auth/auth_screen.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/User/presentation/views/dashboard/user_dashboard.dart';
import 'package:mobile/Owner/presentation/views/dashboard/owner_dashboard.dart';
import 'package:mobile/User/presentation/views/dashboard/home/food_detail.dart';
import 'package:mobile/User/presentation/views/dashboard/home/home_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/home/search_result_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/cart/cart_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/checkout/checkout_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/menu/edit_food_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/report/report_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/support/support_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/profile/edit_profile_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/profile/change_password_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/orders/order_detail_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/promotions/add_edit_promo_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/promotions/promo_detail_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/profile/edit_profile_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/profile/change_password_screen.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/core/models/promo_model.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
// Shipper views
import 'package:mobile/Shipper/views/shipper_dashboard.dart';
import 'package:mobile/Shipper/views/order_detail.dart';
import 'package:mobile/Shipper/views/order_history.dart';
import 'package:mobile/Shipper/views/profile.dart' as shipper_profile;
import 'package:mobile/Shipper/views/live_tracking.dart';
import 'package:mobile/Shipper/views/pickup_confirm.dart';
import 'package:mobile/Shipper/views/delivery_confirm.dart';

// Route names
const String welcomeRoute = '/';
const String authRoute = '/auth';

// User routes
const String userDashboardRoute = '/user-dashboard';
const String foodDetailRoute = '/food-detail';
const String homeRoute = '/home';
const String searchResultRoute = '/search-result';
const String cartRoute = '/cart';
const String checkoutRoute = '/checkout';
const String orderHistoryRoute = '/order-history';
const String userEditProfileRoute = '/user/edit-profile';
const String userChangePasswordRoute = '/user/change-password';

// Owner routes
const String ownerDashboardRoute = '/owner-dashboard';
const String ownerEditFoodRoute = '/owner/edit-food';
const String ownerReportRoute = '/owner/report';
const String ownerSupportRoute = '/owner/support';
const String ownerEditProfileRoute = '/owner/edit-profile';
const String ownerChangePasswordRoute = '/owner/change-password';
const String ownerOrderDetailRoute = '/owner/order-detail';
const String ownerAddEditPromoRoute = '/owner/add-edit-promo';
const String ownerPromoDetailRoute = '/owner/promo-detail';

// Shipper routes
const String shipperDashboardRoute = '/shipper/dashboard';
const String shipperOrderDetailRoute = '/shipper/order-detail';
const String shipperHistoryRoute = '/shipper/history';
const String shipperProfileRoute = '/shipper/profile';
const String shipperTrackingRoute = '/shipper/tracking';
const String shipperPickupConfirmRoute = '/shipper/pickup-confirm';
const String shipperDeliveryConfirmRoute = '/shipper/delivery-confirm';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcomeRoute:
        return MaterialPageRoute(
          builder: (_) => Obx(() {
            final authController = Get.find<AuthController>();
            if (authController.state == AuthState.authenticated) {
              final user = authController.currentUser;
              if (user != null && user.role == UserRole.owner) {
                return const OwnerDashboardScreen();
              } else if (user != null && user.role == UserRole.shipper) {
                return const ShipperDashboard();
              } else {
                return const UserDashboardScreen();
              }
            } else if (authController.state == AuthState.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const WelcomeScreen();
            }
          }),
        );

      case authRoute:
        return MaterialPageRoute(builder: (_) => const AuthScreen());

      case userDashboardRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              UserDashboardScreen(initialIndex: args?['initialIndex'] ?? 0),
        );

      case ownerDashboardRoute:
        return MaterialPageRoute(builder: (_) => const OwnerDashboardScreen());

      case foodDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => FoodDetail(food: args['food'], tag: args['tag']),
        );

      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case searchResultRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SearchResultScreen(
            searchString: args['searchString'],
            foundFoodList: args['foundFoodList'],
          ),
        );

      case cartRoute:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case checkoutRoute:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      // Owner routes
      case ownerEditFoodRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditFoodScreen(food: args?['food']),
        );

      case ownerReportRoute:
        return MaterialPageRoute(builder: (_) => const ReportScreen());

      case ownerSupportRoute:
        return MaterialPageRoute(builder: (_) => const SupportScreen());

      case ownerEditProfileRoute:
        final restaurantArg = settings.arguments as RestaurantModel?;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(restaurant: restaurantArg),
        );

      case ownerChangePasswordRoute:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case ownerOrderDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: args['order'] as OrderModel),
        );

      case ownerAddEditPromoRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddEditPromoScreen(
            promo: args?['promo'] as PromoModel?,
            restaurantId: args?['restaurantId'] as String?,
          ),
        );

      case ownerPromoDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PromoDetailScreen(promo: args['promo'] as PromoModel),
        );

      // Shipper routes
      case shipperDashboardRoute:
        return MaterialPageRoute(builder: (_) => const ShipperDashboard());

      case shipperOrderDetailRoute:
        final args = settings.arguments as ShipperOrder;
        return MaterialPageRoute(builder: (_) => OrderDetail(order: args));

      case shipperHistoryRoute:
        return MaterialPageRoute(builder: (_) => const OrderHistory());

      case shipperProfileRoute:
        return MaterialPageRoute(
          builder: (_) => const shipper_profile.ShipperProfile(),
        );

      case shipperTrackingRoute:
        return MaterialPageRoute(builder: (_) => const LiveTracking());

      case shipperPickupConfirmRoute:
        final args = settings.arguments as ShipperOrder;
        return MaterialPageRoute(builder: (_) => PickupConfirm(order: args));

      case shipperDeliveryConfirmRoute:
        final args = settings.arguments as ShipperOrder;
        return MaterialPageRoute(builder: (_) => DeliveryConfirm(order: args));

      // User profile routes
      case userEditProfileRoute:
        return MaterialPageRoute(builder: (_) => const UserEditProfileScreen());

      case userChangePasswordRoute:
        return MaterialPageRoute(
          builder: (_) => const UserChangePasswordScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
