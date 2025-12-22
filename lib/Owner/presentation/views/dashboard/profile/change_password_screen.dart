import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/change_password_controller.dart';
import 'package:mobile/User/utils/utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ChangePasswordController _controller = ChangePasswordController();

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
                labelText: "Confirm Password",
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
          ],
        ),
      ),
    );
  }
}
