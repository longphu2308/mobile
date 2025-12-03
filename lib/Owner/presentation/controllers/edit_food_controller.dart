import 'package:flutter/material.dart';

class EditFoodController {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFFFF6B1D);

  late TextEditingController _nameCtl;
  late TextEditingController _priceCtl;
  late TextEditingController _descCtl;
  late TextEditingController _imageCtl;
  String _category = 'Món chính';
  bool _available = true;

  // Tuỳ chọn món
  Map<String, String> _options = {'Size': 'Vừa', 'Topping': 'Không'};

  final List<String> _categories = ['Món chính', 'Đồ uống', 'Combo'];

  EditFoodController(Map<String, dynamic>? food) {
    final f = food;
    _nameCtl = TextEditingController(text: f?['name'] ?? '');
    _priceCtl = TextEditingController(text: f?['price']?.toString() ?? '');
    _descCtl = TextEditingController(text: f?['desc'] ?? '');
    _imageCtl = TextEditingController(text: f?['image'] ?? '');
    _category = f?['category'] ?? 'Món chính';
    _available = f?['available'] ?? true;
    _options = Map<String, String>.from(f?['options'] ?? _options);
  }

  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get nameCtl => _nameCtl;
  TextEditingController get priceCtl => _priceCtl;
  TextEditingController get descCtl => _descCtl;
  TextEditingController get imageCtl => _imageCtl;
  String get category => _category;
  bool get available => _available;
  Map<String, String> get options => _options;
  List<String> get categories => _categories;

  set category(String value) => _category = value;
  set available(bool value) => _available = value;

  void addOption(String key, String value) {
    _options[key] = value;
  }

  void removeOption(String key) {
    _options.remove(key);
  }

  Map<String, dynamic> save(Map<String, dynamic>? food) {
    if (!_formKey.currentState!.validate()) return {};
    final res = {
      'id': food != null
          ? food['id']
          : 'F${DateTime.now().millisecondsSinceEpoch}',
      'name': _nameCtl.text.trim(),
      'price': int.tryParse(_priceCtl.text.trim()) ?? 0,
      'desc': _descCtl.text.trim(),
      'available': _available,
      'category': _category,
      'image': _imageCtl.text.trim(),
      'options': _options,
    };
    return res;
  }

  void dispose() {
    _nameCtl.dispose();
    _priceCtl.dispose();
    _descCtl.dispose();
    _imageCtl.dispose();
  }
}