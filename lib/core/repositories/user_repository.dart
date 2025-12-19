import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/models/user_model.dart';

class UserRepository {
  final _supabase = SupabaseService().client;

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        return UserModel.fromMap(data, userId);
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
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) {
        updateData['full_name'] = fullName;
      }
      if (phone != null) {
        updateData['phone'] = phone;
      }
      if (address != null) {
        updateData['address'] = address;
      }
      if (profileImageUrl != null) {
        updateData['profile_image_url'] = profileImageUrl;
      }

      await _supabase.from('users').update(updateData).eq('user_id', userId);
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
      final data = await _supabase.from('users').select();

      return (data as List)
          .map((item) => UserModel.fromMap(item, item['user_id']))
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
      final data = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .limit(1)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return UserModel.fromMap(data, data['user_id']);
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
      await _supabase.from('users').delete().eq('user_id', userId);
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi xóa người dùng: ${e.toString()}',
        code: 'delete_user_error',
      );
    }
  }
}
