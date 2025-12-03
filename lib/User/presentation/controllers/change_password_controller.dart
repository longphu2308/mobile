import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserChangePasswordController {
  final TextEditingController currentCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void dispose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<bool> validateAndUpdate(BuildContext context) async {
    // Validate inputs
    if (currentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter current password'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (newCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter new password'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (newCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (newCtrl.text != confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirm password does not match'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Get current user
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentCtrl.text,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Update password
      await currentUser.updatePassword(newCtrl.text);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error changing password';
      if (e.code == 'wrong-password') {
        errorMessage = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
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

