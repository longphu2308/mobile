import 'package:flutter/material.dart';
import 'package:mobile/config/routes.dart';
import 'package:mobile/User/utils/utils.dart';

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
      initialRoute: welcomeRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}