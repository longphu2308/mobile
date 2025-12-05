import 'package:flutter/material.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserChangePasswordController {
  final TextEditingController currentCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();
  final _supabase = SupabaseService().client;

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

    try {
      // Supabase updateUser for password change
      await _supabase.auth.updateUser(
        UserAttributes(password: newCtrl.text),
      );

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
    } catch (e) {
      String errorMessage = 'Error changing password: ${e.toString()}';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}

