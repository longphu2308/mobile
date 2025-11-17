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
import 'package:mobile/Owner/presentation/views/dashboard/menu/edit_food_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/report/report_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/support/support_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/profile/edit_profile_screen.dart';
import 'package:mobile/Owner/presentation/views/dashboard/profile/change_password_screen.dart';

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

// Owner routes
const String ownerDashboardRoute = '/owner-dashboard';
const String ownerEditFoodRoute = '/owner/edit-food';
const String ownerReportRoute = '/owner/report';
const String ownerSupportRoute = '/owner/support';
const String ownerEditProfileRoute = '/owner/edit-profile';
const String ownerChangePasswordRoute = '/owner/change-password';

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
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => UserDashboardScreen(
            initialIndex: args?['initialIndex'] ?? 0,
          ),
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
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case ownerChangePasswordRoute:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
