import 'package:flutter/material.dart';
import 'package:mobile/User/views/auth/welcome_screen.dart';
import 'package:mobile/User/views/auth/auth_screen.dart';
import 'package:mobile/User/views/auth/forgot_password.dart';
import 'package:mobile/User/views/dashboard/dashboard.dart';
import 'package:mobile/User/views/dashboard/home/food_detail.dart';
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
        dashboardRoute: (context) => const DashboardScreen(),
        foodDetailRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return FoodDetail(
            food: args['food'],
            tag: args['tag'],
          );
        },
      },
    );
  }
}