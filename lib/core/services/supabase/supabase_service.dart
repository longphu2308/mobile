import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // Supabase client getter
  SupabaseClient get client => Supabase.instance.client;

  // Auth getter
  GoTrueClient get auth => client.auth;

  // Database getter
  SupabaseQueryBuilder from(String table) => client.from(table);

  // Get current user
  User? get currentUser => auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Get user ID
  String? get userId => currentUser?.id;

  // Initialize Supabase
  static Future<void> initialize() async {
    // Get Supabase credentials from environment variables
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Supabase credentials not found in .env file. '
        'Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }
}
