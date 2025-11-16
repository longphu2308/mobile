import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:mobile/User/presentation/views/dashboard/order_history/order_history_screen.dart';

// Route names
const String welcomeRoute = '/';
const String authRoute = '/auth';
const String userDashboardRoute = '/user-dashboard';
const String ownerDashboardRoute = '/owner-dashboard';
const String foodDetailRoute = '/food-detail';
const String homeRoute = '/home';
const String searchResultRoute = '/search-result';
const String cartRoute = '/cart';
const String checkoutRoute = '/checkout';
const String orderHistoryRoute = '/order-history';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcomeRoute:
        return MaterialPageRoute(
          builder: (_) => Consumer<AuthController>(
            builder: (context, authController, _) {
              if (authController.state == AuthState.authenticated) {
                final user = authController.currentUser;
                if (user != null && user.role == 'owner') {
                  return const OwnerDashboardScreen();
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
            },
          ),
        );

      case authRoute:
        return MaterialPageRoute(builder: (_) => const AuthScreen());

      case userDashboardRoute:
        return MaterialPageRoute(builder: (_) => const UserDashboardScreen());

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

      case orderHistoryRoute:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
