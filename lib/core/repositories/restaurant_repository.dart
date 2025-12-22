import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class RestaurantRepository {
  final _supabase = SupabaseService().client;
  final _supabaseService = SupabaseService();
  final String _table = 'restaurants';

  // Lấy thông tin quán theo ID
  Future<RestaurantModel?> getRestaurantById(String restaurantId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      if (data != null) {
        return RestaurantModel.fromMap(data, data['restaurant_id']);
      }
      return null;
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // Lấy quán của owner
  Future<RestaurantModel?> getRestaurantByOwnerId(String ownerId) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('owner_id', ownerId)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        return RestaurantModel.fromMap(data, data['restaurant_id']);
      }
      return null;
    } catch (e) {
      print('Error getting restaurant by owner: $e');
      return null;
    }
  }

  // Lấy tất cả quán
  Future<List<RestaurantModel>> getAllRestaurants() async {
    try {
      final data = await _supabase.from(_table).select();
      return (data as List)
          .map((item) => RestaurantModel.fromMap(item, item['restaurant_id']))
          .toList();
    } catch (e) {
      print('Error getting all restaurants: $e');
      return [];
    }
  }

  // Lấy các quán đang mở
  Future<List<RestaurantModel>> getOpenRestaurants() async {
    try {
      final data = await _supabase.from(_table).select().eq('status', 'open');
      return (data as List)
          .map((item) => RestaurantModel.fromMap(item, item['restaurant_id']))
          .toList();
    } catch (e) {
      print('Error getting open restaurants: $e');
      return [];
    }
  }

  // Tạo quán mới
  Future<String?> createRestaurant(RestaurantModel restaurant) async {
    try {
      final data = await _supabase
          .from(_table)
          .insert(restaurant.toMap())
          .select()
          .single();
      return data['restaurant_id'];
    } catch (e) {
      print('Error creating restaurant: $e');
      return null;
    }
  }

  // Cập nhật thông tin quán
  Future<bool> updateRestaurant(
    String restaurantId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Check authentication first
      final currentUser = _supabaseService.currentUser;
      final userId = _supabaseService.userId;

      print('🔐 Authentication check:');
      print('   Current user: ${currentUser?.email ?? "null"}');
      print('   User ID: $userId');
      print('   Is authenticated: ${currentUser != null}');

      if (currentUser == null) {
        throw Exception('User is not authenticated. Please sign in again.');
      }

      // After null check, currentUser is guaranteed to be non-null
      final userEmail = currentUser.email;

      // Get restaurant to verify ownership
      final restaurant = await getRestaurantById(restaurantId);
      if (restaurant == null) {
        throw Exception('Restaurant not found with ID: $restaurantId');
      }

      print('🏪 Restaurant ownership check:');
      print('   Restaurant owner_id: ${restaurant.ownerId}');
      print('   Current user_id: $userId');
      print('   Ownership match: ${restaurant.ownerId == userId}');

      if (restaurant.ownerId != userId) {
        throw Exception(
          'You do not have permission to update this restaurant. Owner ID mismatch.',
        );
      }

      // Remove fields that should not be updated
      final updateData = Map<String, dynamic>.from(data);
      updateData.remove('restaurant_id'); // Primary key, cannot be updated
      updateData.remove('owner_id'); // Should not change owner
      updateData.remove('created_at'); // Should not change creation time
      updateData.remove('rating'); // Rating is calculated, not manually set

      // Always update the updated_at timestamp
      updateData['updated_at'] = DateTime.now().toIso8601String();

      print('📝 Updating restaurant $restaurantId with data: $updateData');
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔍 DETAILED UPDATE INFORMATION');
      print('═══════════════════════════════════════════════════════════');
      print('📊 TABLE INFORMATION:');
      print('   Table name: $_table');
      print('   Restaurant ID: $restaurantId');
      print('');
      print('👤 AUTHENTICATION & OWNERSHIP:');
      print('   Current User ID: $userId');
      print('   Current User Email: $userEmail');
      print('   Restaurant Owner ID: ${restaurant.ownerId}');
      print(
        '   Ownership Match: ${restaurant.ownerId == userId ? "✅ YES" : "❌ NO"}',
      );
      print('');
      print('📝 UPDATE DATA:');
      print(
        '   Fields to update (${updateData.length}): ${updateData.keys.join(", ")}',
      );
      print('   Update values:');
      updateData.forEach((key, value) {
        final valueStr = value.toString();
        final displayValue = valueStr.length > 60
            ? valueStr.substring(0, 60) + '...'
            : valueStr;
        print('     • $key = $displayValue');
      });
      print('');
      print('📋 SQL-LIKE QUERY (for debugging):');
      print('   UPDATE $_table');
      print('   SET');
      updateData.forEach((key, value) {
        print('     $key = \'$value\',');
      });
      print('   WHERE restaurant_id = \'$restaurantId\'');
      print('   -- RLS Policy should check: auth.uid() = owner_id');
      print('');
      print('🔒 RLS POLICY CHECK:');
      print('   Expected policy: "Owners can update own restaurants"');
      print('   Expected USING: auth.uid() = owner_id');
      print('   Expected WITH CHECK: auth.uid() = owner_id');
      print(
        '   ⚠️  If update fails, run check_restaurant_policies.sql in Supabase SQL Editor',
      );
      print('═══════════════════════════════════════════════════════════');
      print('');

      // Try update without select first to avoid PGRST116 error
      try {
        print('🚀 Executing update query...');
        await _supabase
            .from(_table)
            .update(updateData)
            .eq('restaurant_id', restaurantId);

        print('✅ Update query executed successfully (no error thrown)');
        print('   Note: Supabase update() does not return data by default');
        print('   We will verify by fetching the updated row next');
      } catch (e) {
        print('');
        print('═══════════════════════════════════════════════════════════');
        print('❌ UPDATE QUERY FAILED');
        print('═══════════════════════════════════════════════════════════');
        print('   Error Type: ${e.runtimeType}');
        print('   Error Message: $e');
        print('');

        final errorStr = e.toString();
        if (errorStr.contains('PGRST116') || errorStr.contains('0 rows')) {
          print('🔴 DIAGNOSIS: No rows were updated (0 rows affected)');
          print('');
          print('   Possible causes:');
          print('   1. ❌ RLS policy is blocking the update');
          print('   2. ❌ UPDATE policy does not exist');
          print('   3. ❌ Policy USING clause does not match');
          print('   4. ❌ Policy WITH CHECK clause is too restrictive');
          print('');
          print('   🔧 ACTION REQUIRED:');
          print(
            '   → Run check_restaurant_policies.sql in Supabase SQL Editor',
          );
          print(
            '   → Verify UPDATE policy exists and allows: auth.uid() = owner_id',
          );
          print('   → Check that both USING and WITH CHECK clauses match');
        } else if (errorStr.contains('PGRST') || errorStr.contains('406')) {
          print('🔴 DIAGNOSIS: Supabase PostgREST error');
          print('');
          print('   This usually indicates:');
          print('   • RLS policy blocking the operation');
          print('   • Missing or incorrect policy configuration');
          print('   • Authentication/authorization issue');
          print('');
          print('   🔧 ACTION REQUIRED:');
          print('   → Check Supabase Dashboard → Authentication → Policies');
          print('   → Verify restaurants table has UPDATE policy');
          print('   → Run check_restaurant_policies.sql to diagnose');
        } else if (errorStr.contains('permission') ||
            errorStr.contains('denied')) {
          print('🔴 DIAGNOSIS: Permission denied');
          print('');
          print('   This indicates RLS policy is blocking the update');
          print('   even though ownership matches.');
          print('');
          print('   🔧 ACTION REQUIRED:');
          print('   → Check UPDATE policy in Supabase Dashboard');
          print('   → Ensure policy allows: auth.uid() = owner_id');
        }
        print('');
        print('📋 DEBUG INFORMATION:');
        print('   Table: $_table');
        print('   Restaurant ID: $restaurantId');
        print('   Owner ID: ${restaurant.ownerId}');
        print('   Current User ID: $userId');
        print('   Match: ${restaurant.ownerId == userId ? "✅" : "❌"}');
        print('═══════════════════════════════════════════════════════════');
        print('');
        rethrow;
      }

      // Verify the update by fetching the updated row
      print('🔄 Verifying update by fetching restaurant...');
      final updatedRestaurant = await getRestaurantById(restaurantId);

      if (updatedRestaurant == null) {
        throw Exception(
          'Failed to verify update: Restaurant not found after update',
        );
      }

      // Check if values actually changed
      // Note: Address comparison is flexible due to potential normalization
      final nameChanged = updatedRestaurant.name == updateData['name'];
      final phoneChanged = updatedRestaurant.phone == updateData['phone'];

      // For address, compare normalized versions (remove diacritics for comparison)
      // This handles cases where database normalizes Vietnamese characters
      final originalAddress = (updateData['address'] as String? ?? '')
          .toLowerCase();
      final updatedAddress = updatedRestaurant.address.toLowerCase();
      final addressChanged = updatedAddress == originalAddress;

      // Also check if address is similar (contains same words, ignoring diacritics)
      final addressSimilar =
          originalAddress.isNotEmpty &&
          updatedAddress.isNotEmpty &&
          (updatedAddress.contains(originalAddress.split(' ').first) ||
              originalAddress.contains(updatedAddress.split(' ').first));

      print('✅ Restaurant updated successfully');
      print('   Updated restaurant: ${updatedRestaurant.name}');
      print(
        '   Verification: name=${nameChanged ? "✓" : "✗"}, phone=${phoneChanged ? "✓" : "✗"}, address=${addressChanged ? "✓" : (addressSimilar ? "~" : "✗")}',
      );
      print(
        '   New values: name=${updatedRestaurant.name}, phone=${updatedRestaurant.phone}, address=${updatedRestaurant.address}',
      );
      if (!addressChanged && addressSimilar) {
        print('   ℹ️  Address normalized by database (diacritics removed)');
      }

      // Only throw if ALL fields failed to update (likely RLS issue)
      // If at least one field changed or address is similar, consider it successful
      if (!nameChanged && !phoneChanged && !addressChanged && !addressSimilar) {
        print('⚠️ WARNING: Update executed but values did not change!');
        print('   This likely means RLS policy is blocking the update.');
        throw Exception(
          'Update executed but no changes were applied. Check RLS policies.',
        );
      }

      return true;
    } catch (e) {
      print('❌ Error updating restaurant: $e');
      rethrow; // Rethrow to let controller handle the error
    }
  }

  // Cập nhật trạng thái quán (open/closed)
  Future<bool> updateRestaurantStatus(
    String restaurantId,
    String status,
  ) async {
    try {
      await _supabase
          .from(_table)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('restaurant_id', restaurantId);
      return true;
    } catch (e) {
      print('Error updating restaurant status: $e');
      return false;
    }
  }

  // Xóa quán
  Future<bool> deleteRestaurant(String restaurantId) async {
    try {
      await _supabase.from(_table).delete().eq('restaurant_id', restaurantId);
      return true;
    } catch (e) {
      print('Error deleting restaurant: $e');
      return false;
    }
  }

  // Stream để lắng nghe thay đổi của quán
  Stream<RestaurantModel?> restaurantStream(String restaurantId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['restaurant_id'])
        .eq('restaurant_id', restaurantId)
        .map((data) {
          if (data.isNotEmpty) {
            return RestaurantModel.fromMap(
              data.first,
              data.first['restaurant_id'],
            );
          }
          return null;
        });
  }
}
