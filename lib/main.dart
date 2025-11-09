import 'package:flutter/material.dart';
import 'package:mobile/User/views/auth/welcome_screen.dart';
import 'package:mobile/User/views/auth/auth_screen.dart';
import 'package:mobile/User/views/auth/forgot_password.dart';
import 'package:mobile/User/views/dashboard/dashboard.dart';
import 'package:mobile/User/views/dashboard/home/food_detail.dart';
// Shipper pages
import 'package:mobile/Shipper/views/shipper_dashboard.dart';
import 'package:mobile/Shipper/views/order_detail.dart';
import 'package:mobile/Shipper/views/pickup_confirm.dart';
import 'package:mobile/Shipper/views/delivery_confirm.dart';
import 'package:mobile/Shipper/views/earnings.dart';
import 'package:mobile/Shipper/views/order_history.dart';
import 'package:mobile/Shipper/views/profile.dart';
import 'package:mobile/Shipper/views/live_tracking.dart';
import 'package:mobile/Shipper/views/shift.dart';
import 'package:mobile/Shipper/views/support_chat.dart';
import 'package:mobile/Shipper/views/notifications.dart';
import 'package:mobile/User/utils/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        authRoute: (context) => const AuthScreen(),
        forgotPasswordRoute: (context) => const ForgotPasswordScreen(),
        // shipper routes
        ShipperDashboard.routeName: (context) => const ShipperDashboard(),
        OrderDetail.routeName: (context) => const OrderDetail(),
        PickupConfirm.routeName: (context) => const PickupConfirm(),
        DeliveryConfirm.routeName: (context) => const DeliveryConfirm(),
        EarningsPage.routeName: (context) => const EarningsPage(),
        OrderHistory.routeName: (context) => const OrderHistory(),
        ShipperProfile.routeName: (context) => const ShipperProfile(),
        LiveTracking.routeName: (context) => const LiveTracking(),
        ShiftPage.routeName: (context) => const ShiftPage(),
        SupportChat.routeName: (context) => const SupportChat(),
        NotificationsPage.routeName: (context) => const NotificationsPage(),
        dashboardRoute: (context) => const DashboardScreen(),
        foodDetailRoute: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return FoodDetail(food: args['food'], tag: args['tag']);
        },
      },
    );
  }
}
