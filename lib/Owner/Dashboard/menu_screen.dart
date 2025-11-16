import 'package:flutter/material.dart';
import 'edit_food_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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

  List<Map<String, dynamic>> get _filteredMenu {
    if (_selectedCategory == 'Tất cả') return _menu;
    return _menu.where((m) => m['category'] == _selectedCategory).toList();
  }

  void _toggleAvailability(int index) {
    setState(() {
      _filteredMenu[index]['available'] = !_filteredMenu[index]['available'];
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _menu.removeWhere((item) => item['id'] == id);
    });
  }

  Future<void> _openEdit(Map<String, dynamic> food) async {
    final res = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditFoodScreen(food: food)),
    );
    if (res != null) {
      setState(() {
        final idx = _menu.indexWhere((i) => i['id'] == res['id']);
        if (idx != -1) _menu[idx] = res;
      });
    }
  }

  void _addNew() async {
    final res = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const EditFoodScreen()),
    );
    if (res != null) {
      setState(() {
        _menu.add(res);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Quản lý menu', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            onPressed: _addNew,
            icon: Icon(Icons.add, color: primaryColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bộ lọc danh mục
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Danh sách món
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMenu.length,
              itemBuilder: (context, idx) {
                final item = _filteredMenu[idx];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      // Ảnh món
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item['image'] != ''
                            ? Image.network(item['image'],
                                width: 60, height: 60, fit: BoxFit.cover)
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.fastfood, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Thông tin món
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('₫ ${item['price']}',
                                style: const TextStyle(color: Colors.black54)),
                            Text(
                              item['category'],
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Nút chức năng
                      Column(
                        children: [
                          IconButton(
                              onPressed: () => _openEdit(item),
                              icon: const Icon(Icons.edit, color: Colors.black54)),
                          IconButton(
                              onPressed: () => _deleteItem(item['id']),
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent)),
                        ],
                      ),
                      Switch(
                        value: item['available'],
                        onChanged: (_) => _toggleAvailability(idx),
                        activeColor: primaryColor,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
