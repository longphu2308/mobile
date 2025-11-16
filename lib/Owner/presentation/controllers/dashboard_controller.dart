import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  bool isOpen = true;

  void toggleOpen() {
    isOpen = !isOpen;
    notifyListeners();
  }
}