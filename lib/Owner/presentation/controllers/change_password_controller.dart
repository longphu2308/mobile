import 'package:flutter/material.dart';

class ChangePasswordController {
  final TextEditingController currentCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  void dispose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  bool validateAndUpdate(BuildContext context) {
    if (newCtrl.text == confirmCtrl.text) {
      // Logic to update password, e.g., call API
      Navigator.pop(context);
      return true;
    }
    return false;
  }
}