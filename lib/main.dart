import 'package:flutter/material.dart';
import 'package:mobile/core/services/firebase/firebase_service.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/app.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const MyApp());
}

class FoodStoreApp extends StatelessWidget {
  const FoodStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: getProviders(), child: const App());
  }

  void _navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // đóng Drawer
  }
}
