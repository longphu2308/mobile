import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: const Text('Support', style: TextStyle(color: blackColor)),
        leading: BackButton(color: blackColor),
      ),
      body: const Center(child: Text('Support content here')),
    );
  }
}
