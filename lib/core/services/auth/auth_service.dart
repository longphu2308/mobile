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
      // Check if phone already exists
      final phoneQuery = await _supabase
          .from('users')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (phoneQuery != null) {
        throw AuthException(
          message: 'Số điện thoại đã được sử dụng',
          code: 'phone-already-in-use',
        );
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
        fullName: fullName,
        phone: phone,
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Insert user data into users table
      await _supabase.from('users').insert(user.toMap());

      return user;
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
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
        throw AuthException(message: 'Email hoặc mật khẩu không đúng');
      }

      return await _getUserData(response.user!.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Email hoặc mật khẩu không đúng');
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
