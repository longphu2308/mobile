import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:mobile/core/repositories/auth_repository.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/services/food/food_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final SupabaseService _supabase = SupabaseService();

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final Rx<UserProfileModel?> _currentProfile = Rx<UserProfileModel?>(null);
  final RxList<UserAddressModel> _addresses = <UserAddressModel>[].obs;
  final Rx<AuthState> _state = AuthState.initial.obs;
  final RxnString _errorMessage = RxnString(null);
  final RxBool _isLoading = false.obs;

  // Getters
  UserModel? get currentUser => _currentUser.value;
  UserProfileModel? get currentProfile => _currentProfile.value;
  List<UserAddressModel> get addresses => _addresses;
  AuthState get state => _state.value;
  String? get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _currentUser.value != null;

  // Convenience getters cho profile
  String? get fullName => _currentProfile.value?.fullName;
  String? get phone => _currentProfile.value?.phone;
  String? get avatarUrl => _currentProfile.value?.avatarUrl;
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
          _currentUser.value = userData;
          await _loadProfile(userData.userId);
          await _loadAddresses(userData.userId);
          _state.value = AuthState.authenticated;
        } else {
          // User authenticated but no data in database, sign out
          await _authRepository.signOut();
          _currentUser.value = null;
          _currentProfile.value = null;
          _addresses.clear();
          _state.value = AuthState.unauthenticated;
        }
      } catch (e) {
        // If error loading, sign out
        await _authRepository.signOut();
        _currentUser.value = null;
        _currentProfile.value = null;
        _addresses.clear();
        _state.value = AuthState.unauthenticated;
      }
    } else {
      // User is signed out
      _currentUser.value = null;
      _currentProfile.value = null;
      _addresses.clear();
      _state.value = AuthState.unauthenticated;
    }
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data != null) {
        _currentProfile.value = UserProfileModel.fromMap(data);
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
      _addresses.assignAll(
        (data as List).map((item) => UserAddressModel.fromMap(item)).toList(),
      );
    } catch (e) {
      _addresses.clear();
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    UserRole role = UserRole.user,
    Map<String, String>? additionalData,
  }) async {
    try {
      print('\n🎯 AuthController.signUp called');
      print('📧 Email: $email');
      print('👤 Name: $fullName');
      print('📱 Phone: $phone');
      print('🎭 Role: $role');
      print('📦 Additional data: $additionalData');
      
      _isLoading.value = true;
      _errorMessage.value = null;

      print('🔄 Calling authRepository.signUp...');
      UserModel user = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
        additionalData: additionalData,
      );

      print('✅ User created successfully: ${user.userId}');
      _currentUser.value = user;
      
      print('📖 Loading profile...');
      await _loadProfile(user.userId);
      
      print('📍 Loading addresses...');
      await _loadAddresses(user.userId);
      
      _state.value = AuthState.authenticated;
      _isLoading.value = false;
      print('🎉 SignUp process completed in controller');
      
      // Load foods now that user is authenticated
      print('📊 Loading foods after signup...');
      try {
        final foodService = Get.find<FoodService>();
        await foodService.loadFoods();
        print('✅ Foods loaded successfully');
      } catch (e) {
        print('⚠️ Failed to load foods: $e');
      }
      
      return true;
    } on AuthException catch (e) {
      print('❌ AuthException in controller: ${e.message}');
      _errorMessage.value = e.message;
      _state.value = AuthState.error;
      _isLoading.value = false;
      return false;
    } catch (e, stackTrace) {
      print('❌ Unexpected error in controller: $e');
      print('📍 Stack trace: $stackTrace');
      _errorMessage.value = 'Đã có lỗi xảy ra: $e';
      _state.value = AuthState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      UserModel user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      _currentUser.value = user;
      _state.value = AuthState.authenticated;
      _isLoading.value = false;
      
      // Load foods now that user is authenticated
      print('📊 Loading foods after sign in...');
      try {
        final foodService = Get.find<FoodService>();
        await foodService.loadFoods();
        print('✅ Foods loaded successfully');
      } catch (e) {
        print('⚠️ Failed to load foods: $e');
      }
      
      return true;
    } on AuthException catch (e) {
      _errorMessage.value = e.message;
      _state.value = AuthState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    try {
      _isLoading.value = true;
      await _authRepository.signOut();

      _currentUser.value = null;
      _state.value = AuthState.unauthenticated;
      _errorMessage.value = null;
      _isLoading.value = false;
      return true;
    } on AuthException catch (e) {
      _errorMessage.value = e.message;
      _state.value = AuthState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Get current user from Firestore
  Future<void> loadCurrentUser() async {
    try {
      _isLoading.value = true;
      UserModel? user = await _authRepository.getCurrentUser();

      if (user != null) {
        _currentUser.value = user;
        await _loadProfile(user.userId);
        await _loadAddresses(user.userId);
        _state.value = AuthState.authenticated;
        
        // Load foods now that user is authenticated
        print('📊 Loading foods for existing session...');
        try {
          final foodService = Get.find<FoodService>();
          await foodService.loadFoods();
          print('✅ Foods loaded successfully');
        } catch (e) {
          print('⚠️ Failed to load foods: $e');
        }
      } else {
        _currentUser.value = null;
        _currentProfile.value = null;
        _addresses.clear();
        _state.value = AuthState.unauthenticated;
      }
      _isLoading.value = false;
    } on AuthException catch (e) {
      _errorMessage.value = e.message;
      _state.value = AuthState.error;
      _isLoading.value = false;
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_currentUser.value == null) return false;

    try {
      _isLoading.value = true;

      if (_currentProfile.value != null) {
        // Update existing profile
        await _supabase
            .from('user_profiles')
            .update({
              'full_name': fullName ?? _currentProfile.value!.fullName,
              'phone': phone ?? _currentProfile.value!.phone,
              'avatar_url': avatarUrl ?? _currentProfile.value!.avatarUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', _currentUser.value!.userId);
      } else {
        // Create new profile
        await _supabase.from('user_profiles').insert({
          'user_id': _currentUser.value!.userId,
          'full_name': fullName,
          'phone': phone,
          'avatar_url': avatarUrl,
        });
      }

      await _loadProfile(_currentUser.value!.userId);
      _isLoading.value = false;
      return true;
    } catch (e) {
      _isLoading.value = false;
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
    if (_currentUser.value == null) return false;

    try {
      _isLoading.value = true;

      // If setting as default, unset other defaults
      if (isDefault) {
        await _supabase
            .from('user_addresses')
            .update({'is_default': false})
            .eq('user_id', _currentUser.value!.userId);
      }

      await _supabase.from('user_addresses').insert({
        'user_id': _currentUser.value!.userId,
        'label': label.value,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
      });

      await _loadAddresses(_currentUser.value!.userId);
      _isLoading.value = false;
      return true;
    } catch (e) {
      _isLoading.value = false;
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage.value = null;
  }

  /// Reset controller
  void reset() {
    _currentUser.value = null;
    _currentProfile.value = null;
    _addresses.clear();
    _state.value = AuthState.initial;
    _errorMessage.value = null;
    _isLoading.value = false;
  }
}
