import 'package:flutter/material.dart';
import 'package:mobile/core/services/firebase/firebase_service.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/app.dart';
import 'package:provider/provider.dart';
// import 'package:mobile/core/services/firestore_seed_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  // Seed dữ liệu mẫu vào Firestore (chỉ chạy một lần)
  // final seeder = FirestoreSeedData();
  // await seeder.seedAllData();

  runApp(MultiProvider(providers: getProviders(), child: const App()));
}
