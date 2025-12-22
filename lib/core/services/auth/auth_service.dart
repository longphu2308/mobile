import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/services/geocoding_service.dart';

class AuthService {
  final SupabaseService _supabase = SupabaseService();

  // Sign up
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    UserRole role = UserRole.user,
    Map<String, String>? additionalData,
  }) async {
    try {
      print('\n🔵 SignUp started for role: $role');
      print('📧 Email: $email');
      print('📱 Phone: $phone');
      print('👤 Name: $fullName');
      print('🔑 Additional data: $additionalData');
      
      // Check if phone already exists in user_profiles
      print('🔍 Checking phone existence...');
      final phoneQuery = await _supabase
          .from('user_profiles')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (phoneQuery != null) {
        print('❌ Phone already exists');
        throw AuthException(
          message: 'Số điện thoại đã được sử dụng',
          code: 'phone-already-in-use',
        );
      }
      print('✅ Phone check passed');

      // Check if email already exists in auth
      print('🔍 Checking email existence...');
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        print('⚠️ User exists in DB, trying sign in...');
        // User exists in DB, try to sign in instead
        return await signIn(email: email, password: password);
      }
      print('✅ Email check passed');

      // Sign up with Supabase Auth
      print('🔐 Creating auth user...');
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        print('❌ Auth signup failed - no user returned');
        throw AuthException(message: 'Không thể tạo tài khoản');
      }
      print('✅ Auth user created: ${response.user!.id}');

      final user = UserModel(
        userId: response.user!.id,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Insert user data into users table
      print('💾 Inserting user to users table...');
      await _supabase.from('users').insert(user.toMap());
      print('✅ User inserted');

      // Insert profile data into user_profiles table
      print('💾 Inserting user profile...');
      final profile = UserProfileModel(
        profileId: '',
        userId: response.user!.id,
        fullName: fullName,
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _supabase.from('user_profiles').insert(profile.toInsertMap());
      print('✅ User profile inserted');
      
      // Handle role-specific data
      if (role == UserRole.shipper && additionalData != null) {
        try {
          print('🚚 Creating shipper profile...');
          await _supabase.from('shipper_profiles').insert({
            'user_id': response.user!.id,
            'vehicle_type': additionalData['vehicle_type'],
            'vehicle_plate': additionalData['vehicle_plate'],
            'license_number': additionalData['license_number'],
            'is_available': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('✅ Shipper profile created');
        } catch (e) {
          print('❌ Error creating shipper profile: $e');
          throw AuthException(message: 'Không thể tạo hồ sơ shipper: $e');
        }
      } else if (role == UserRole.owner && additionalData != null) {
        try {
          print('\n🏪 Creating restaurant for owner...');
          print('📦 Additional data received: $additionalData');
          
          // Validate data
          if (additionalData['restaurant_name'] == null || additionalData['restaurant_name']!.isEmpty) {
            throw Exception('Restaurant name is missing');
          }
          if (additionalData['restaurant_address'] == null || additionalData['restaurant_address']!.isEmpty) {
            throw Exception('Restaurant address is missing');
          }
          if (additionalData['restaurant_phone'] == null || additionalData['restaurant_phone']!.isEmpty) {
            throw Exception('Restaurant phone is missing');
          }
          
          // Geocode address to get coordinates
          print('🌍 Geocoding restaurant address...');
          final coordinates = await GeocodingService().getCoordinatesFromAddress(
            additionalData['restaurant_address']!
          );
          
          double? latitude;
          double? longitude;
          
          if (coordinates != null) {
            latitude = coordinates.latitude;
            longitude = coordinates.longitude;
            print('✅ Coordinates found: lat=$latitude, lon=$longitude');
          } else {
            print('⚠️ Geocoding failed, restaurant will be created without coordinates');
          }
          
          final Map<String, dynamic> restaurantData = {
            'owner_id': response.user!.id,
            'name': additionalData['restaurant_name'],
            'address': additionalData['restaurant_address'],
            'phone': additionalData['restaurant_phone'],
            'status': 'closed',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          // Add coordinates if available
          if (latitude != null && longitude != null) {
            restaurantData['latitude'] = latitude;
            restaurantData['longitude'] = longitude;
          }
          
          print('💾 Restaurant data to insert: $restaurantData');
          
          final result = await _supabase.from('restaurants').insert(restaurantData);
          print('📤 Insert result: $result');
          print('✅ Restaurant created successfully');
        } catch (e, stackTrace) {
          print('❌ Error creating restaurant: $e');
          print('📍 Stack trace: $stackTrace');
          throw AuthException(message: 'Không thể tạo nhà hàng: $e');
        }
      }
      
      print('🎉 SignUp completed successfully');
      return user;
    } on AuthException catch (e) {
      print('\n⚠️ AuthException caught: ${e.message}');
      if (e.message.contains('already registered') ||
          e.message.contains('User already registered')) {
        // User exists in auth but not in DB, try to get auth user and create DB record
        try {
          final AuthResponse response = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (response.user != null) {
            // Check if user exists in DB
            final dbUser = await _supabase
                .from('users')
                .select()
                .eq('user_id', response.user!.id)
                .maybeSingle();

            if (dbUser != null) {
              // User exists in both, return it
              return UserModel.fromMap(dbUser, dbUser['user_id']);
            } else {
              // User exists in auth but not in DB, create DB record
              final user = UserModel(
                userId: response.user!.id,
                email: email,
                role: role,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await _supabase.from('users').insert(user.toMap());

              // Create profile
              final profile = UserProfileModel(
                profileId: '',
                userId: response.user!.id,
                fullName: fullName,
                phone: phone,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await _supabase
                  .from('user_profiles')
                  .insert(profile.toInsertMap());
                  
              // Handle role-specific data
              if (role == UserRole.shipper && additionalData != null) {
                try {
                  await _supabase.from('shipper_profiles').insert({
                    'user_id': response.user!.id,
                    'vehicle_type': additionalData['vehicle_type'],
                    'vehicle_plate': additionalData['vehicle_plate'],
                    'license_number': additionalData['license_number'],
                    'is_available': true,
                    'created_at': DateTime.now().toIso8601String(),
                    'updated_at': DateTime.now().toIso8601String(),
                  });
                } catch (e) {
                  print('❌ Error creating shipper profile: $e');
                }
              } else if (role == UserRole.owner && additionalData != null) {
                try {
                  // Geocode address
                  final coordinates = await GeocodingService().getCoordinatesFromAddress(
                    additionalData['restaurant_address']!
                  );
                  
                  final Map<String, dynamic> restaurantData = {
                    'owner_id': response.user!.id,
                    'name': additionalData['restaurant_name'],
                    'address': additionalData['restaurant_address'],
                    'phone': additionalData['restaurant_phone'],
                    'status': 'closed',
                    'created_at': DateTime.now().toIso8601String(),
                    'updated_at': DateTime.now().toIso8601String(),
                  };
                  
                  if (coordinates != null) {
                    restaurantData['latitude'] = coordinates.latitude;
                    restaurantData['longitude'] = coordinates.longitude;
                  }
                  
                  await _supabase.from('restaurants').insert(restaurantData);
                } catch (e) {
                  print('❌ Error creating restaurant: $e');
                }
              }

              return user;
            }
          }
        } catch (loginError) {
          throw AuthException(
            message: 'Email đã được sử dụng với mật khẩu khác',
            code: 'email-already-in-use',
          );
        }
        throw AuthException(
          message: 'Email đã được sử dụng',
          code: 'email-already-in-use',
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      print('\n❌ Unexpected error in signUp: $e');
      print('📍 Stack trace: $stackTrace');
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Đã có lỗi xảy ra. Vui lòng thử lại: $e');
    }
  }

  // Sign in
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Sai tài khoản hoặc mật khẩu');
      }

      return await _getUserData(response.user!.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Sai tài khoản hoặc mật khẩu');
    }
  }

  // Get user from Supabase
  Future<UserModel> getUser(String uid) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('user_id', uid)
          .single();

      return UserModel.fromMap(data, uid);
    } catch (e) {
      throw AuthException(message: 'Failed to load user');
    }
  }

  Future<void> signOut() => _supabase.signOut();

  Stream<AuthState> authStateChanges() => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.currentUser;

  Future<UserModel> _getUserData(String uid) async {
    final data = await _supabase
        .from('users')
        .select()
        .eq('user_id', uid)
        .single();

    return UserModel.fromMap(data, uid);
  }
}
