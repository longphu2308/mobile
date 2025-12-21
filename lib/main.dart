import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  await SupabaseService.initialize();

  // Initialize GetX controllers
  initializeControllers();

  runApp(const App());
}
