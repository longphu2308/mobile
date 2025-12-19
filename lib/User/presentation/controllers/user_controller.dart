import 'package:flutter/material.dart';
import 'package:mobile/core/repositories/user_repository.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/errors/app_exception.dart';

enum UserState { initial, loading, success, error }

class UserController extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _user;
  UserProfileModel? _profile;
  List<UserAddressModel> _addresses = [];
  List<UserModel> _users = [];
  UserState _state = UserState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  UserProfileModel? get profile => _profile;
  List<UserAddressModel> get addresses => _addresses;
  List<UserModel> get users => _users;
  UserState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Convenience getters for profile data
  String? get fullName => _profile?.fullName;
  String? get phone => _profile?.phone;
  String? get avatarUrl => _profile?.avatarUrl;
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
      _setLoading(true);
      _errorMessage = null;

      UserModel? user = await _userRepository.getUserById(userId);

      if (user != null) {
        _user = user;
        // Also load profile and addresses
        await _loadProfile(userId);
        await _loadAddresses(userId);
        _state = UserState.success;
      } else {
        _state = UserState.error;
        _errorMessage = 'Người dùng không tồn tại';
      }
      _setLoading(false);
      notifyListeners();
      return user != null;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = UserState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Load user profile
  Future<void> _loadProfile(String userId) async {
    try {
      _profile = await _userRepository.getUserProfile(userId);
    } catch (e) {
      // Ignore error, profile may not exist
    }
  }

  /// Load user addresses
  Future<void> _loadAddresses(String userId) async {
    try {
      _addresses = await _userRepository.getUserAddresses(userId);
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
      _setLoading(true);
      _errorMessage = null;

      await _userRepository.updateUserProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      // Reload profile
      await _loadProfile(userId);

      _state = UserState.success;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = UserState.error;
      _setLoading(false);
      notifyListeners();
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
      _setLoading(true);
      _errorMessage = null;

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

      _state = UserState.success;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = UserState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Delete user address
  Future<bool> deleteAddress(String addressId, String userId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _userRepository.deleteUserAddress(addressId);

      // Reload addresses
      await _loadAddresses(userId);

      _state = UserState.success;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = UserState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Get all users
  Future<bool> getAllUsers() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _users = await _userRepository.getAllUsers();
      _state = UserState.success;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = UserState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Search user by email
  Future<bool> searchUserByEmail(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      UserModel? user = await _userRepository.getUserByEmail(email);

      if (user != null) {
        _user = user;
        _state = UserState.success;
      } else {
        _state = UserState.error;
        _errorMessage = 'Không tìm thấy người dùng với email này';
      }
      _setLoading(false);
      notifyListeners();
      return user != null;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = UserState.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _userRepository.deleteUser(userId);

      if (_user != null && _user!.userId == userId) {
        _user = null;
      }

      _state = UserState.success;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      _state = UserState.error;
      _setLoading(false);
      notifyListeners();
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
    _user = null;
    _profile = null;
    _addresses = [];
    _users = [];
    _state = UserState.initial;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
