import 'package:flutter/material.dart';

class EditProfileController {
  final TextEditingController nameCtrl = TextEditingController(text: "Nguyen Van A");
  final TextEditingController emailCtrl = TextEditingController(text: "owner@example.com");
  final TextEditingController phoneCtrl = TextEditingController(text: "0901234567");

  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
  }

  void save(BuildContext context) {
    // Logic to save profile, e.g., call API
    Navigator.pop(context);
  }
}