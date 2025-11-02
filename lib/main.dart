import 'package:flutter/material.dart';
import 'package:mobile/ui/views/auth/auth_screen.dart';
import 'package:mobile/ui/views/dashboard/dashboard.dart';
import 'package:mobile/utils/utils.dart';

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
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        dashboardRoute: (context) => const DashboardScreen(),
      },
    );
  }
}