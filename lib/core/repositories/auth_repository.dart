import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/services/auth/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    UserRole role = UserRole.user,
    Map<String, String>? additionalData,
  }) => _authService.signUp(
    email: email,
    password: password,
    fullName: fullName,
    phone: phone,
    role: role,
    additionalData: additionalData,
  );

  Future<UserModel> signIn({required String email, required String password}) =>
      _authService.signIn(email: email, password: password);

  Future<void> signOut() => _authService.signOut();

  Stream<AuthState> get auth => _authService.authStateChanges();

  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    try {
      return _authService.getUser(user.id);
    } catch (e) {
      return null;
    }
  }
}
