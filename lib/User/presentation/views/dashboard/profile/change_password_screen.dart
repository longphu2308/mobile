import 'package:flutter/material.dart';
import 'package:mobile/User/presentation/controllers/change_password_controller.dart';
import 'package:mobile/User/utils/utils.dart';

class UserChangePasswordScreen extends StatefulWidget {
  const UserChangePasswordScreen({super.key});

  @override
  State<UserChangePasswordScreen> createState() =>
      _UserChangePasswordScreenState();
}

class _UserChangePasswordScreenState extends State<UserChangePasswordScreen> {
  final UserChangePasswordController _controller =
      UserChangePasswordController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: const Text(
          "Change Password",
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: blackColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _controller.currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () => _controller.validateAndUpdate(context),
                child: const Text(
                  "Update Password",
                  style: TextStyle(color: whiteColor, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


