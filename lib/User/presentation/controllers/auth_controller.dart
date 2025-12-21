import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:mobile/core/repositories/auth_repository.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SupabaseService _supabase = SupabaseService();

  UserModel? _currentUser;
  UserProfileModel? _currentProfile;
  List<UserAddressModel> _addresses = [];
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  UserProfileModel? get currentProfile => _currentProfile;
  List<UserAddressModel> get addresses => _addresses;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Convenience getters cho profile
  String? get fullName => _currentProfile?.fullName;
  String? get phone => _currentProfile?.phone;
  String? get avatarUrl => _currentProfile?.avatarUrl;
  UserAddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  String? get address => defaultAddress?.address;

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
          await _loadProfile(userData.userId);
          await _loadAddresses(userData.userId);
          _state = AuthState.authenticated;
        } else {
          // User authenticated but no data in database, sign out
          await _authRepository.signOut();
          _currentUser = null;
          _currentProfile = null;
          _addresses = [];
          _state = AuthState.unauthenticated;
        }
      } catch (e) {
        // If error loading, sign out
        await _authRepository.signOut();
        _currentUser = null;
        _currentProfile = null;
        _addresses = [];
        _state = AuthState.unauthenticated;
      }
    } else {
      // User is signed out
      _currentUser = null;
      _currentProfile = null;
      _addresses = [];
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data != null) {
        _currentProfile = UserProfileModel.fromMap(data);
      }
    } catch (e) {
      // Ignore error, profile may not exist yet
    }
  }

  Future<void> _loadAddresses(String userId) async {
    try {
      final data = await _supabase
          .from('user_addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);
      _addresses = (data as List)
          .map((item) => UserAddressModel.fromMap(item))
          .toList();
    } catch (e) {
      _addresses = [];
    }
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
      await _loadProfile(user.userId);
      await _loadAddresses(user.userId);
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
        await _loadProfile(user.userId);
        await _loadAddresses(user.userId);
        _state = AuthState.authenticated;
      } else {
        _currentUser = null;
        _currentProfile = null;
        _addresses = [];
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

  /// Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);

      if (_currentProfile != null) {
        // Update existing profile
        await _supabase
            .from('user_profiles')
            .update({
              'full_name': fullName ?? _currentProfile!.fullName,
              'phone': phone ?? _currentProfile!.phone,
              'avatar_url': avatarUrl ?? _currentProfile!.avatarUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', _currentUser!.userId);
      } else {
        // Create new profile
        await _supabase.from('user_profiles').insert({
          'user_id': _currentUser!.userId,
          'full_name': fullName,
          'phone': phone,
          'avatar_url': avatarUrl,
        });
      }

      await _loadProfile(_currentUser!.userId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  /// Add address
  Future<bool> addAddress({
    required String address,
    AddressLabel label = AddressLabel.home,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);

      // If setting as default, unset other defaults
      if (isDefault) {
        await _supabase
            .from('user_addresses')
            .update({'is_default': false})
            .eq('user_id', _currentUser!.userId);
      }

      await _supabase.from('user_addresses').insert({
        'user_id': _currentUser!.userId,
        'label': label.value,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      });

      await _loadAddresses(_currentUser!.userId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
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
    _currentProfile = null;
    _addresses = [];
    _state = AuthState.initial;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
