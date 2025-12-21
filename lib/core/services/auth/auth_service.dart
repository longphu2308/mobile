import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class AuthService {
  final SupabaseService _supabase = SupabaseService();

  // Sign up
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      // Check if phone already exists in user_profiles
      final phoneQuery = await _supabase
          .from('user_profiles')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (phoneQuery != null) {
        throw AuthException(
          message: 'Số điện thoại đã được sử dụng',
          code: 'phone-already-in-use',
        );
      }

      // Check if email already exists in auth
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        // User exists in DB, try to sign in instead
        return await signIn(email: email, password: password);
      }

      // Sign up with Supabase Auth
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Không thể tạo tài khoản');
      }

      final user = UserModel(
        userId: response.user!.id,
        email: email,
        role: UserRole.user,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Insert user data into users table
      await _supabase.from('users').insert(user.toMap());

      // Insert profile data into user_profiles table
      final profile = UserProfileModel(
        profileId: '',
        userId: response.user!.id,
        fullName: fullName,
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _supabase.from('user_profiles').insert(profile.toInsertMap());

      return user;
    } on AuthException catch (e) {
      if (e.message.contains('already registered') ||
          e.message.contains('User already registered')) {
        // User exists in auth but not in DB, try to get auth user and create DB record
        try {
          final AuthResponse response = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (response.user != null) {
            // Check if user exists in DB
            final dbUser = await _supabase
                .from('users')
                .select()
                .eq('user_id', response.user!.id)
                .maybeSingle();

            if (dbUser != null) {
              // User exists in both, return it
              return UserModel.fromMap(dbUser, dbUser['user_id']);
            } else {
              // User exists in auth but not in DB, create DB record
              final user = UserModel(
                userId: response.user!.id,
                email: email,
                role: UserRole.user,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await _supabase.from('users').insert(user.toMap());

              // Create profile
              final profile = UserProfileModel(
                profileId: '',
                userId: response.user!.id,
                fullName: fullName,
                phone: phone,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await _supabase
                  .from('user_profiles')
                  .insert(profile.toInsertMap());

              return user;
            }
          }
        } catch (loginError) {
          throw AuthException(
            message: 'Email đã được sử dụng với mật khẩu khác',
            code: 'email-already-in-use',
          );
        }
        throw AuthException(
          message: 'Email đã được sử dụng',
          code: 'email-already-in-use',
        );
      }
      rethrow;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  // Sign in
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Sai tài khoản hoặc mật khẩu');
      }

      return await _getUserData(response.user!.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Sai tài khoản hoặc mật khẩu');
    }
  }

  // Get user from Supabase
  Future<UserModel> getUser(String uid) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('user_id', uid)
          .single();

      return UserModel.fromMap(data, uid);
    } catch (e) {
      throw AuthException(message: 'Failed to load user');
    }
  }

  Future<void> signOut() => _supabase.signOut();

  Stream<AuthState> authStateChanges() => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.currentUser;

  Future<UserModel> _getUserData(String uid) async {
    final data = await _supabase
        .from('users')
        .select()
        .eq('user_id', uid)
        .single();

    return UserModel.fromMap(data, uid);
  }
}
