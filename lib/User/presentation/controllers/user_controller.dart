import 'package:get/get.dart';
import 'package:mobile/core/repositories/user_repository.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/errors/app_exception.dart';

enum UserState { initial, loading, success, error }

class UserController extends GetxController {
  final UserRepository _userRepository;

  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final Rx<UserProfileModel?> _profile = Rx<UserProfileModel?>(null);
  final RxList<UserAddressModel> _addresses = <UserAddressModel>[].obs;
  final RxList<UserModel> _users = <UserModel>[].obs;
  final Rx<UserState> _state = UserState.initial.obs;
  final RxnString _errorMessage = RxnString(null);
  final RxBool _isLoading = false.obs;

  // Getters
  UserModel? get user => _user.value;
  UserProfileModel? get profile => _profile.value;
  List<UserAddressModel> get addresses => _addresses;
  List<UserModel> get users => _users;
  UserState get state => _state.value;
  String? get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;

  // Convenience getters for profile data
  String? get fullName => _profile.value?.fullName;
  String? get phone => _profile.value?.phone;
  String? get avatarUrl => _profile.value?.avatarUrl;
  UserAddressModel? get defaultAddress => _addresses.isNotEmpty
      ? _addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _addresses.first,
        )
      : null;
  String? get address => defaultAddress?.address;

  UserController({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  /// Get user by ID
  Future<bool> getUserById(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      UserModel? user = await _userRepository.getUserById(userId);

      if (user != null) {
        _user.value = user;
        // Also load profile and addresses
        await _loadProfile(userId);
        await _loadAddresses(userId);
        _state.value = UserState.success;
      } else {
        _state.value = UserState.error;
        _errorMessage.value = 'Người dùng không tồn tại';
      }
      _isLoading.value = false;
      return user != null;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = UserState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Load user profile
  Future<void> _loadProfile(String userId) async {
    try {
      _profile.value = await _userRepository.getUserProfile(userId);
    } catch (e) {
      // Ignore error, profile may not exist
    }
  }

  /// Load user addresses
  Future<void> _loadAddresses(String userId) async {
    try {
      _addresses.assignAll(await _userRepository.getUserAddresses(userId));
    } catch (e) {
      // Ignore error, addresses may not exist
    }
  }

  /// Update user profile (now updates user_profiles table)
  Future<bool> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _userRepository.updateUserProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      // Reload profile
      await _loadProfile(userId);

      _state.value = UserState.success;
      _isLoading.value = false;
      return true;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = UserState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Add or update user address
  Future<bool> upsertAddress({
    required String userId,
    String? addressId,
    required String address,
    String? label,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _userRepository.upsertUserAddress(
        userId: userId,
        addressId: addressId,
        address: address,
        label: label,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      // Reload addresses
      await _loadAddresses(userId);

      _state.value = UserState.success;
      _isLoading.value = false;
      return true;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = UserState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Delete user address
  Future<bool> deleteAddress(String addressId, String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _userRepository.deleteUserAddress(addressId);

      // Reload addresses
      await _loadAddresses(userId);

      _state.value = UserState.success;
      _isLoading.value = false;
      return true;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = UserState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Get all users
  Future<bool> getAllUsers() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      _users.assignAll(await _userRepository.getAllUsers());
      _state.value = UserState.success;
      _isLoading.value = false;
      return true;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = UserState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Search user by email
  Future<bool> searchUserByEmail(String email) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      UserModel? user = await _userRepository.getUserByEmail(email);

      if (user != null) {
        _user.value = user;
        _state.value = UserState.success;
      } else {
        _state.value = UserState.error;
        _errorMessage.value = 'Không tìm thấy người dùng với email này';
      }
      _isLoading.value = false;
      return user != null;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = UserState.error;
      _isLoading.value = false;
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _userRepository.deleteUser(userId);

      if (_user.value != null && _user.value!.userId == userId) {
        _user.value = null;
      }

      _state.value = UserState.success;
      _isLoading.value = false;
      return true;
    } on FirestoreException catch (e) {
      _errorMessage.value = e.message;
      _state.value = UserState.error;
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
    _user.value = null;
    _profile.value = null;
    _addresses.clear();
    _users.clear();
    _state.value = UserState.initial;
    _errorMessage.value = null;
    _isLoading.value = false;
  }
}
