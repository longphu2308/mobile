import 'package:flutter/material.dart';

// Spacing Widget
class YBox extends StatelessWidget {
  final double height;

  const YBox(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}