import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/menu_controller.dart';
import 'package:mobile/Owner/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:mobile/config/routes.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late MenuScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MenuScreenController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openEdit(Map<String, dynamic> food) async {
    final res = await Navigator.pushNamed<Map<String, dynamic>>(
      context,
      ownerEditFoodRoute,
      arguments: {'food': food},
    );
    if (res != null) {
      _controller.updateItem(res['id'], res);
    }
  }

  void _addNew() async {
    final res = await Navigator.pushNamed<Map<String, dynamic>>(
      context,
      ownerEditFoodRoute,
    );
    if (res != null) {
      _controller.addItem(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: const Text('Quản lý menu', style: TextStyle(color: blackColor)),
        actions: [
          IconButton(
            onPressed: _addNew,
            icon: Icon(Icons.add, color: primaryColor),
          ),
        ],
      ),
      body: ChangeNotifierProvider<MenuScreenController>(
        create: (_) => _controller,
        child: Consumer<MenuScreenController>(
          builder: (context, controller, child) {
            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: whiteColor,
                title: const Text(
                  'Quản lý menu',
                  style: TextStyle(color: blackColor),
                ),
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
                      itemCount: controller.categories.length,
                      itemBuilder: (context, i) {
                        final cat = controller.categories[i];
                        final selected = controller.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(
                              color: selected ? whiteColor : blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (_) => controller.selectCategory(cat),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Danh sách món
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.filteredMenu.length,
                      itemBuilder: (context, idx) {
                        final item = controller.filteredMenu[idx];
                        return MenuItemCard(
                          item: item,
                          onEdit: () => _openEdit(item),
                          onDelete: () => controller.deleteItem(item['id']),
                          onToggle: (value) =>
                              controller.toggleAvailability(idx),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
