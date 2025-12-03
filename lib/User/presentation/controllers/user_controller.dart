import 'package:flutter/material.dart';
import 'package:mobile/core/repositories/user_repository.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/errors/app_exception.dart';

enum UserState { initial, loading, success, error }

class UserController extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _user;
  List<UserModel> _users = [];
  UserState _state = UserState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  List<UserModel> get users => _users;
  UserState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

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

  /// Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _userRepository.updateUserProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        address: address,
        profileImageUrl: profileImageUrl,
      );

      // Cập nhật user hiện tại
      if (_user != null && _user!.userId == userId) {
        _user = _user!.copyWith(
          fullName: fullName ?? _user!.fullName,
          phone: phone ?? _user!.phone,
          address: address ?? _user!.address,
        );
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
    _users = [];
    _state = UserState.initial;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
