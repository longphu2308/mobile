import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  // Bucket name
  static const String bucketName = 'profile_images';

  /// Upload image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String?> uploadFoodImage(File imageFile, String fileName) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'food_${timestamp}_$fileName';
      final filePath = 'foods/$uniqueFileName';

      print('📤 Uploading image: $filePath');

      // Upload file
      await _client.storage
          .from(bucketName)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(filePath);

      print('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Upload restaurant image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String?> uploadRestaurantImage(File imageFile, String fileName) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'restaurant_${timestamp}_$fileName';
      final filePath = 'restaurants/$uniqueFileName';

      print('📤 Uploading restaurant image: $filePath');

      // Upload file
      await _client.storage
          .from(bucketName)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(filePath);

      print('✅ Restaurant image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading restaurant image: $e');
      return null;
    }
  }

  /// Delete image from Supabase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the path after the bucket name
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        print('Invalid image URL format');
        return false;
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print('🗑️ Deleting image: $filePath');

      await _client.storage.from(bucketName).remove([filePath]);

      print('✅ Image deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }
}
