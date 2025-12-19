import 'package:flutter/material.dart';
import 'package:mobile/User/presentation/controllers/user_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class UserEditProfileController {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
  }

  void initFromUser(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    nameCtrl.text = authController.fullName ?? '';
    phoneCtrl.text = authController.phone ?? '';
    addressCtrl.text = authController.address ?? '';
  }

  Future<bool> save(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final userController = Provider.of<UserController>(context, listen: false);

    final user = authController.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      // Update profile first (fullName, phone)
      final success = await userController.updateUserProfile(
        userId: user.userId,
        fullName: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      );

      // Update address separately if provided
      if (addressCtrl.text.trim().isNotEmpty) {
        await userController.upsertAddress(
          userId: user.userId,
          address: addressCtrl.text.trim(),
          isDefault: true,
        );
      }

      if (success) {
        // Reload user data
        await authController.loadCurrentUser();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
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
                userController.errorMessage ?? 'Error updating profile',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
