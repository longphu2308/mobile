import 'package:flutter/material.dart';

class PromotionsController extends ChangeNotifier {
  final List<Map<String, dynamic>> _promos = [
    {
      'code': 'WELCOME10',
      'type': 'Giảm %',
      'value': 10,
      'maxDiscount': 10000,
      'active': true,
      'used': 25,
    },
    {
      'code': 'FREESHIP',
      'type': 'Miễn phí vận chuyển',
      'value': 0,
      'maxDiscount': 0,
      'active': true,
      'used': 40,
    },
    {
      'code': 'FLASHSALE',
      'type': 'Chiến dịch',
      'value': 20,
      'maxDiscount': 15000,
      'active': false,
      'used': 12,
    },
  ];

  List<Map<String, dynamic>> get promos => _promos;

  void toggleActive(int idx) {
    _promos[idx]['active'] = !_promos[idx]['active'];
    notifyListeners();
  }

  void deletePromo(int idx) {
    _promos.removeAt(idx);
    notifyListeners();
  }

  void addPromo(Map<String, dynamic> promo) {
    _promos.add(promo);
    notifyListeners();
  }
}