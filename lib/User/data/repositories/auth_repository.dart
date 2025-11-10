import 'package:mobile/User/domain/models/user.dart';
import 'package:mobile/core/services/auth/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) =>
      _authService.signUp(email: email, password: password, fullName: fullName);

  Future<UserModel> signIn({required String email, required String password}) =>
      _authService.signIn(email: email, password: password);

  Future<void> signOut() => _authService.signOut();

  Stream<FirebaseUser?> get auth => _authService.authStateChanges();

  Future<UserModel?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    return _authService.getUser(user.uid);
  }
}
