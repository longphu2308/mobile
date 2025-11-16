import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/config/routes.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/User/presentation/views/auth/welcome_screen.dart';
import 'package:mobile/User/presentation/views/dashboard/dashboard.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home: Consumer<AuthController>(
        builder: (context, authController, _) {
          // Show appropriate screen based on auth state
          if (authController.state == AuthState.authenticated) {
            return const DashboardScreen();
          } else if (authController.state == AuthState.initial) {
            // Show loading while checking auth state
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return const WelcomeScreen();
          }
        },
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
