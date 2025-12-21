import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/menu_controller.dart';
import 'package:mobile/Owner/presentation/views/dashboard/menu/add_edit_food_screen.dart';
import 'package:mobile/Owner/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:provider/provider.dart';

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
    _controller.loadMenu();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openEdit(FoodModel food) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditFoodScreen(food: food)),
    );
  }

  void _addNew() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _controller,
          child: const AddEditFoodScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<MenuScreenController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: whiteColor,
              title: const Text(
                'Quản lý menu',
                style: TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
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
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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
                  child: controller.filteredMenu.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fastfood,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có món ăn nào',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.filteredMenu.length,
                          itemBuilder: (context, idx) {
                            final item = controller.filteredMenu[idx];
                            return MenuItemCard(
                              item: item,
                              onEdit: () => _openEdit(item),
                              onDelete: () => controller.deleteItem(item.id),
                              onToggle: (value) =>
                                  controller.toggleAvailability(item.id, value),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
