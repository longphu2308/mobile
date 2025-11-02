import 'package:flutter/material.dart';

// Colors
const Color primaryColor = Color(0xFFFF6B35);
const Color whiteColor = Color(0xFFFFFFFF);
const Color blackColor = Color(0xFF000000);

// Dimensions
const double radius = 16.0;
const double horizontalPadding = 24.0;

// Routes
const String dashboardRoute = '/dashboard';

// Spacing Widget
class YBox extends StatelessWidget {
  final double height;

  const YBox(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}


