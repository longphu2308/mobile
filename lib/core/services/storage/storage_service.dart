import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/errors/app_exception.dart';

class StorageService {
  final _supabase = SupabaseService().client;
  static const String _bucketName = 'profile_images';
  static const int _maxFileSizeMB = 50;
  static const int _maxFileSizeBytes = _maxFileSizeMB * 1024 * 1024;

  /// Upload profile image to Supabase storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Check if user is authenticated
      var currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw StorageException(
          message: 'Bạn cần đăng nhập để upload ảnh',
          code: 'not_authenticated',
        );
      }

      // Refresh session to ensure valid token
      try {
        final session = _supabase.auth.currentSession;
        if (session == null) {
          throw StorageException(
            message: 'Session không hợp lệ. Vui lòng đăng nhập lại.',
            code: 'invalid_session',
          );
        }
        
        // Check if session is expired or about to expire (within 5 minutes)
        final expiresAt = session.expiresAt;
        if (expiresAt != null) {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final timeUntilExpiry = expiresAt - now;
          
          // Refresh if expires within 5 minutes
          if (timeUntilExpiry < 300) {
            await _supabase.auth.refreshSession();
            currentUser = _supabase.auth.currentUser;
          }
        }
      } catch (e) {
        if (e is StorageException) rethrow;
        // If refresh fails, try to continue with current session
        // Session might still be valid
      }

      // Verify userId matches authenticated user
      if (currentUser?.id != userId) {
        throw StorageException(
          message: 'Không có quyền upload ảnh cho user này',
          code: 'unauthorized',
        );
      }

      // Check file size (50MB limit)
      final fileSize = await imageFile.length();
      if (fileSize > _maxFileSizeBytes) {
        throw StorageException(
          message: 'Kích thước file vượt quá giới hạn ${_maxFileSizeMB}MB',
          code: 'file_too_large',
        );
      }

      // Generate unique file name: userId_timestamp.extension
      final fileName = imageFile.path.split('/').last;
      final extension = fileName.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${userId}_$timestamp.$extension';

      // Upload file to Supabase storage with metadata
      await _supabase.storage.from(_bucketName).uploadBinary(
        uniqueFileName,
        await imageFile.readAsBytes(),
        fileOptions: FileOptions(
          upsert: false,
          cacheControl: '3600',
          contentType: 'image/$extension',
        ),
      );

      // Get public URL
      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(uniqueFileName);

      return publicUrl;
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      
      // Handle specific Supabase errors
      final errorString = e.toString().toLowerCase();
      
      // RLS policy errors
      if (errorString.contains('row-level security policy') || 
          errorString.contains('rls') ||
          errorString.contains('403') ||
          errorString.contains('unauthorized') ||
          errorString.contains('forbidden')) {
        throw StorageException(
          message: 'Không có quyền upload ảnh. Vui lòng:\n1. Kiểm tra bạn đã đăng nhập\n2. Kiểm tra RLS policies trong Supabase Dashboard\n3. Đảm bảo bucket "profile_images" đã được tạo và có policies cho authenticated users',
          code: 'rls_policy_error',
        );
      }
      
      // Authentication errors
      if (errorString.contains('jwt') ||
          errorString.contains('token') ||
          errorString.contains('401') ||
          errorString.contains('unauthenticated')) {
        throw StorageException(
          message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          code: 'auth_expired',
        );
      }
      
      // Network errors
      if (errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('timeout')) {
        throw StorageException(
          message: 'Lỗi kết nối. Vui lòng kiểm tra internet và thử lại.',
          code: 'network_error',
        );
      }
      
      throw StorageException(
        message: 'Lỗi upload ảnh: ${e.toString()}',
        code: 'upload_error',
      );
    }
  }

  /// Delete profile image from Supabase storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file name from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) {
        return;
      }

      // Find the bucket name index and get the file path after it
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        return;
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from(_bucketName).remove([filePath]);
    } catch (e) {
      // Silently fail if file doesn't exist
    }
  }
}


