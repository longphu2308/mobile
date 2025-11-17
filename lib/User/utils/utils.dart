import 'package:flutter/material.dart';
import 'package:mobile/User/state/foodie_store.dart';

// Colors
const Color primaryColor = Color(0xFFFF6B35);
const Color primaryColorDark = Color(0xFFE55A2A);
const Color orangeLight = Color(0xFFFF8C5A);
const Color whiteColor = Color(0xFFFFFFFF);
const Color blackColor = Color(0xFF000000);

// Dimensions
const double radius = 16.0;
const double horizontalPadding = 24.0;
const double verticalPadding = 50.0;

// Routes
const String authRoute = '/auth';
const String dashboardRoute = '/dashboard';
const String foodDetailRoute = '/food-detail';
const String cartRoute = '/cart';
const String checkoutRoute = '/checkout';

// Colors
const Color transparentColor = Color(0x00000000);
const Color blackAccentColor = Color(0xFF000000);
const Color greyColor = Color(0xFF9E9E9E);
const Color bgColor = Color(0xFFF2F2F2);

// Tab Bar Titles
const List<String> tabBarTitle = ['Foods', 'Drinks', 'Snacks', 'Sauces', 'Desserts'];

// Spacing Widget
class YBox extends StatelessWidget {
  final double height;

  const YBox(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

String formatCurrency(num value) {
  final plain = value.toStringAsFixed(0);
  if (plain.length <= 3) return plain;
  final buffer = StringBuffer();
  int count = 0;
  for (int i = plain.length - 1; i >= 0; i--) {
    buffer.write(plain[i]);
    count++;
    if (count == 3 && i != 0) {
      buffer.write(',');
      count = 0;
    }
  }
  return buffer.toString().split('').reversed.join();
}

String deliveryMethodLabel(DeliveryMethod method) {
  switch (method) {
    case DeliveryMethod.door:
      return 'Door delivery';
    case DeliveryMethod.pickup:
      return 'Pick up';
  }
}

String paymentMethodLabel(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Cash';
    case PaymentMethod.bank:
      return 'Bank account';
  }
}



