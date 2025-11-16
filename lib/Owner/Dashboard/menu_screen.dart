// lib/staff/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'edit_food_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<Map<String, dynamic>> _menu = [
    {'id': 'F001', 'name': 'Veggie tomato mix', 'price': 19000, 'available': true},
    {'id': 'F002', 'name': 'Spicy fried rice', 'price': 23500, 'available': true},
    {'id': 'F003', 'name': 'Fish with orange', 'price': 19000, 'available': false},
  ];

  void _toggleAvailability(int index) {
    setState(() {
      _menu[index]['available'] = !_menu[index]['available'];
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _menu.removeAt(index);
    });
  }

  Future<void> _openEdit(int index) async {
    final res = await Navigator.push<Map<String, dynamic>>(context,
        MaterialPageRoute(builder: (_) => EditFoodScreen(food: _menu[index])));
    if (res != null) {
      setState(() {
        _menu[index] = res;
      });
    }
  }

  void _addNew() async {
    final res = await Navigator.push<Map<String, dynamic>>(context,
        MaterialPageRoute(builder: (_) => const EditFoodScreen()));
    if (res != null) {
      setState(() {
        _menu.add(res);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B1D);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Menu', style: TextStyle(color: Colors.black)),
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(onPressed: _addNew, icon: const Icon(Icons.add, color: primaryColor)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _menu.length,
          itemBuilder: (context, idx) {
            final item = _menu[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade100, child: const Icon(Icons.food_bank, color: primaryColor)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('₫ ${item['price']}', style: const TextStyle(color: Colors.black54)),
                  ])),
                  Column(
                    children: [
                      IconButton(onPressed: () => _openEdit(idx), icon: const Icon(Icons.edit, color: Colors.black54)),
                      IconButton(onPressed: () => _deleteItem(idx), icon: const Icon(Icons.delete, color: Colors.redAccent)),
                    ],
                  ),
                  Switch(value: item['available'], onChanged: (_) => _toggleAvailability(idx), activeColor: primaryColor),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
