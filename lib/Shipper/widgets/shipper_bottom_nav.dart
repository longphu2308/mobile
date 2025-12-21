import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

Widget shipperBottomNav(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor: primaryColor,
    onTap: (idx) {
      switch (idx) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(context, '/shipper/dashboard', (r) => false);
          break;
        case 1:
          Navigator.pushNamedAndRemoveUntil(context, '/shipper/history', (r) => false);
          break;
        case 2:
          Navigator.pushNamedAndRemoveUntil(context, '/shipper/profile', (r) => false);
          break;
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
    ],
  );
}
