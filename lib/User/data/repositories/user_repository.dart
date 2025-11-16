import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/firebase/firebase_service.dart';
import 'package:mobile/User/domain/models/user.dart';

class UserRepository {
  final FirebaseService _firebaseService;

  UserRepository({FirebaseService? firebaseService})
    : _firebaseService = firebaseService ?? FirebaseService();

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _firebaseService
          .firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy thông tin người dùng: ${e.toString()}',
        code: 'get_user_error',
      );
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {'updatedAt': DateTime.now()};

      if (fullName != null) updateData['fullName'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (profileImageUrl != null)
        updateData['profileImageUrl'] = profileImageUrl;

      await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .update(updateData);
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi cập nhật hồ sơ: ${e.toString()}',
        code: 'update_profile_error',
      );
    }
  }

  /// Get all users (có thể dùng cho admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseService
          .firestore
          .collection('users')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy danh sách người dùng: ${e.toString()}',
        code: 'get_all_users_error',
      );
    }
  }

  /// Search users by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseService
          .firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return UserModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi tìm kiếm người dùng: ${e.toString()}',
        code: 'search_user_error',
      );
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firebaseService.firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi xóa người dùng: ${e.toString()}',
        code: 'delete_user_error',
      );
    }
  }
}
