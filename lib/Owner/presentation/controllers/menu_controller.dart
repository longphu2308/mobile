import 'package:flutter/material.dart';

class MenuScreenController extends ChangeNotifier {
  final Color primaryColor = const Color(0xFFFF6B1D);

  // Danh mục món
  final List<String> _categories = ['Tất cả', 'Món chính', 'Đồ uống', 'Combo'];

  String _selectedCategory = 'Tất cả';

  final List<Map<String, dynamic>> _menu = [
    {
      'id': 'F001',
      'name': 'Cơm chiên hải sản',
      'price': 35000,
      'available': true,
      'category': 'Món chính',
      'image': '',
      'desc': 'Cơm chiên thơm ngon với hải sản tươi sống',
      'options': {'Size': 'Vừa', 'Topping': 'Không'},
    },
    {
      'id': 'F002',
      'name': 'Trà sữa trân châu',
      'price': 29000,
      'available': true,
      'category': 'Đồ uống',
      'image': '',
      'desc': 'Thức uống ngọt ngào, mát lạnh, topping trân châu dai ngon',
      'options': {'Size': 'Lớn', 'Đá': 'Vừa'},
    },
    {
      'id': 'F003',
      'name': 'Combo ăn trưa',
      'price': 55000,
      'available': false,
      'category': 'Combo',
      'image': '',
      'desc': 'Cơm + Canh + Tráng miệng – đủ chất cho bữa trưa!',
      'options': {},
    },
  ];

  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  List<Map<String, dynamic>> get menu => _menu;

  List<Map<String, dynamic>> get filteredMenu {
    if (_selectedCategory == 'Tất cả') return _menu;
    return _menu.where((m) => m['category'] == _selectedCategory).toList();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleAvailability(int index) {
    final item = filteredMenu[index];
    item['available'] = !item['available'];
    notifyListeners();
  }

  void deleteItem(String id) {
    _menu.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void addItem(Map<String, dynamic> item) {
    _menu.add(item);
    notifyListeners();
  }

  void updateItem(String id, Map<String, dynamic> updatedItem) {
    final idx = _menu.indexWhere((i) => i['id'] == id);
    if (idx != -1) {
      _menu[idx] = updatedItem;
      notifyListeners();
    }
  }
}
