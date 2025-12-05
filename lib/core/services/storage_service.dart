import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String?> uploadImage({
    required File imageFile,
    required String folder,
    String? fileName,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('User not authenticated');
        return null;
      }

      // Generate filename if not provided
      final String finalFileName = fileName ??
          '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';

      // Create reference
      final Reference ref = _storage
          .ref()
          .child(folder)
          .child(userId)
          .child(finalFileName);

      // Upload file
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Show upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            snapshot.bytesTransferred / snapshot.totalBytes * 100;
        debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Upload restaurant profile image
  Future<String?> uploadRestaurantImage(File imageFile) async {
    return uploadImage(
      imageFile: imageFile,
      folder: 'restaurants',
      fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}',
    );
  }

  /// Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('Image deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
}

