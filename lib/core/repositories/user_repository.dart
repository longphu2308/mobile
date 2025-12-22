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

  /// Get user profile by user ID
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        return UserProfileModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy profile người dùng: ${e.toString()}',
        code: 'get_profile_error',
      );
    }
  }

  /// Get user addresses by user ID
  Future<List<UserAddressModel>> getUserAddresses(String userId) async {
    try {
      final data = await _supabase
          .from('user_addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);

      return (data as List)
          .map((item) => UserAddressModel.fromMap(item))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi lấy địa chỉ người dùng: ${e.toString()}',
        code: 'get_addresses_error',
      );
    }
  }

  /// Update user profile (now in user_profiles table)
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
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
      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      // Check if profile exists
      final existing = await _supabase
          .from('user_profiles')
          .select('profile_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('user_profiles')
            .update(updateData)
            .eq('user_id', userId);
      } else {
        // Create new profile
        updateData['user_id'] = userId;
        await _supabase.from('user_profiles').insert(updateData);
      }
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi cập nhật hồ sơ: ${e.toString()}',
        code: 'update_profile_error',
      );
    }
  }

  /// Add or update user address
  Future<void> upsertUserAddress({
    required String userId,
    String? addressId,
    required String address,
    String? label,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      Map<String, dynamic> addressData = {
        'user_id': userId,
        'address': address,
        'label': label ?? 'other',
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (addressId != null) {
        // Update existing
        await _supabase
            .from('user_addresses')
            .update(addressData)
            .eq('address_id', addressId);
      } else {
        // Insert new
        // If this is set as default, unset others first
        if (isDefault) {
          await _supabase
              .from('user_addresses')
              .update({'is_default': false})
              .eq('user_id', userId);
        }
        await _supabase.from('user_addresses').insert(addressData);
      }
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi cập nhật địa chỉ: ${e.toString()}',
        code: 'update_address_error',
      );
    }
  }

  /// Delete user address
  Future<void> deleteUserAddress(String addressId) async {
    try {
      await _supabase
          .from('user_addresses')
          .delete()
          .eq('address_id', addressId);
    } catch (e) {
      throw FirestoreException(
        message: 'Lỗi xóa địa chỉ: ${e.toString()}',
        code: 'delete_address_error',
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
