import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:mobile/core/repositories/auth_repository.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/errors/app_exception.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserModel? _currentUser;
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authRepository.auth.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(supabase.AuthState authState) async {
    final user = authState.session?.user;

    if (user != null) {
      // User is signed in, load user data from Supabase
      try {
        UserModel? userData = await _authRepository.getCurrentUser();
        if (userData != null) {
          _currentUser = userData;
          _state = AuthState.authenticated;
        } else {
          // User authenticated but no data in database, sign out
          await _authRepository.signOut();
          _currentUser = null;
          _state = AuthState.unauthenticated;
        }
      } catch (e) {
        // If error loading, sign out
        await _authRepository.signOut();
        _currentUser = null;
        _state = AuthState.unauthenticated;
      }
    } else {
      // User is signed out
      _currentUser = null;
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      UserModel user = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      _currentUser = user;
      _state = AuthState.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      UserModel user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      _currentUser = user;
      _state = AuthState.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      await _authRepository.signOut();

      _currentUser = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Get current user from Firestore
  Future<void> loadCurrentUser() async {
    try {
      _setLoading(true);
      UserModel? user = await _authRepository.getCurrentUser();

      if (user != null) {
        _currentUser = user;
        _state = AuthState.authenticated;
      } else {
        _currentUser = null;
        _state = AuthState.unauthenticated;
      }
      _setLoading(false);
      notifyListeners();
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Private helper
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// Reset controller
  void reset() {
    _currentUser = null;
    _state = AuthState.initial;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
