import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/Owner/presentation/controllers/menu_controller.dart';
import 'package:mobile/Owner/presentation/views/dashboard/menu/add_edit_food_screen.dart';
import 'package:mobile/Owner/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/core/models/food_model.dart';

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
    _controller = Get.put(MenuScreenController());
    _controller.loadMenu();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openEdit(FoodModel food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditFoodScreen(food: food)),
    );
    if (result != null) {
      _controller.loadMenu(); // Reload menu after editing
    }
  }

  void _addNew() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditFoodScreen()),
    );
    _controller.loadMenu(); // Reload menu after adding
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = _controller;
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: whiteColor,
          automaticallyImplyLeading: false,
          title: const Text(
            'Quản lý menu',
            style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () => _controller.loadMenu(),
              icon: const Icon(Icons.refresh, color: Colors.grey),
              tooltip: 'Làm mới',
            ),
            IconButton(
              onPressed: _addNew,
              icon: const Icon(Icons.add_circle, color: primaryColor, size: 28),
              tooltip: 'Thêm món mới',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Bộ lọc danh mục
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categoryKeys.length,
                itemBuilder: (context, i) {
                  final categoryKey = controller.categoryKeys[i];
                  final categoryLabel =
                      MenuScreenController.categoryMap[categoryKey] ??
                      categoryKey;
                  final selected =
                      controller.selectedCategoryKey == categoryKey;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(categoryLabel),
                      selected: selected,
                      selectedColor: primaryColor,
                      labelStyle: TextStyle(
                        color: selected ? whiteColor : blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) => controller.selectCategory(categoryKey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            // Danh sách món
            Expanded(
              child: controller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _controller.loadMenu(),
                      color: primaryColor,
                      child: controller.filteredMenu.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu,
                                        size: 80,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Chưa có món ăn nào',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Nhấn + để thêm món mới',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: controller.filteredMenu.length,
                              itemBuilder: (context, idx) {
                                final item = controller.filteredMenu[idx];
                                return MenuItemCard(
                                  key: ValueKey(item.id),
                                  item: item,
                                  onEdit: () => _openEdit(item),
                                  onDelete: () =>
                                      controller.deleteItem(item.id),
                                  onToggle: (value) =>
                                      controller.toggleAvailability(
                                        item.id,
                                        item.available,
                                      ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
