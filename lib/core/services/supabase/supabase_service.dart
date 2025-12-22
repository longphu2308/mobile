import 'package:supabase_flutter/supabase_flutter.dart';

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
    await Supabase.initialize(
      url: 'https://yozmcjrvurlmtkigsswj.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlvem1janJ2dXJsbXRraWdzc3dqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5MjkyNTcsImV4cCI6MjA4MDUwNTI1N30.0uQkzWeIR7JAHR9mlvJOjiu6JIaepld727Tgog8YoKU',
    );
  }

  // Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }
}
