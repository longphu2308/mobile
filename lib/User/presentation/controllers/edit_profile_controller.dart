import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/User/presentation/controllers/user_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/services/storage/storage_service.dart';
import 'package:mobile/core/errors/app_exception.dart';
import 'package:provider/provider.dart';

class UserEditProfileController {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedImage;
  String? _currentAvatarUrl;
  bool _isUploadingImage = false;

  File? get selectedImage => _selectedImage;
  String? get currentAvatarUrl => _currentAvatarUrl;
  bool get isUploadingImage => _isUploadingImage;

  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
  }

  void initFromUser(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    if (user != null) {
      nameCtrl.text = user.fullName ?? '';
      phoneCtrl.text = user.phone ?? '';
      addressCtrl.text = user.address ?? '';
      _currentAvatarUrl = user.avatarUrl;
    }
  }

  /// Pick image from gallery or camera
  Future<void> pickImage(BuildContext context, {ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        const maxSize = 50 * 1024 * 1024; // 50MB

        if (fileSize > maxSize) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kích thước file vượt quá giới hạn 50MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        _selectedImage = file;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show image source selection dialog
  /// Returns true if an image was selected or deleted, false otherwise
  Future<bool> showImageSourceDialog(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(dialogContext);
                await pickImage(context, source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(dialogContext);
                await pickImage(context, source: ImageSource.camera);
              },
            ),
            if (_selectedImage != null || _currentAvatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(dialogContext, true);
                  _selectedImage = null;
                  _currentAvatarUrl = null;
                },
              ),
          ],
        ),
      ),
    );
    return result ?? (_selectedImage != null);
  }


  Future<bool> save(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final userController = Provider.of<UserController>(context, listen: false);

    final user = authController.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Người dùng chưa đăng nhập'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    try {
      String? imageUrl = _currentAvatarUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        _isUploadingImage = true;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đang upload ảnh...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        try {
          // Delete old image if exists
          if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
            await _storageService.deleteProfileImage(_currentAvatarUrl!);
          }

          // Upload new image
          imageUrl = await _storageService.uploadProfileImage(
            userId: user.userId,
            imageFile: _selectedImage!,
          );
        } catch (e) {
          _isUploadingImage = false;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e is StorageException ? e.message : 'Lỗi upload ảnh: ${e.toString()}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
        _isUploadingImage = false;
      }

      // Update profile
      final success = await userController.updateUserProfile(
        userId: user.userId,
        fullName: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
        profileImageUrl: imageUrl,
      );

      if (success) {
        // Reload user data
        await authController.loadCurrentUser();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật hồ sơ thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userController.errorMessage ?? 'Lỗi cập nhật hồ sơ',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      _isUploadingImage = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}

