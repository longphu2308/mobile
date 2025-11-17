import 'package:flutter/material.dart';
import 'package:mobile/User/views/auth/welcome_screen.dart';
import 'package:mobile/User/views/auth/auth_screen.dart';
import 'package:mobile/User/views/dashboard/dashboard.dart';
import 'package:mobile/User/views/dashboard/home/food_detail.dart';
import 'package:mobile/User/views/dashboard/cart/cart_screen.dart';
import 'package:mobile/User/views/dashboard/cart/checkout_screen.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/state/foodie_store.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodieStore(),
      child: MaterialApp(
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
          dashboardRoute: (context) => const DashboardScreen(),
          foodDetailRoute: (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return FoodDetail(
              food: args['food'],
              tag: args['tag'],
            );
          },
          cartRoute: (context) => const CartScreen(),
          checkoutRoute: (context) => const CheckoutScreen(),
        },
      ),
    );
  }
}