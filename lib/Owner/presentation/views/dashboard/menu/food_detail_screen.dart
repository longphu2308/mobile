import 'package:flutter/material.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Owner/presentation/views/dashboard/menu/add_edit_food_screen.dart';
import 'package:mobile/Owner/presentation/controllers/menu_controller.dart';
import 'package:provider/provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodModel food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late FoodModel currentFood;

  @override
  void initState() {
    super.initState();
    currentFood = widget.food;
  }

  Future<void> _toggleStatus(MenuScreenController controller) async {
    await controller.toggleAvailability(currentFood.id, currentFood.available);
    setState(() {
      currentFood = currentFood.copyWith(available: !currentFood.available);
    });
  }

  Future<void> _deleteFood(MenuScreenController controller) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá món ăn?'),
        content: Text('Bạn có chắc muốn xoá món "${currentFood.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        await controller.deleteItem(currentFood.id);
        Navigator.pop(context);
      }
    }
  }

  void _openEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditFoodScreen(food: currentFood)),
    ).then((result) {
      if (result != null) {
        setState(() {
          currentFood = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: const Text(
          'Chi tiết món ăn',
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        leading: BackButton(color: blackColor),
        actions: [
          IconButton(
            onPressed: _openEdit,
            icon: const Icon(Icons.edit, color: primaryColor),
          ),
        ],
      ),
      body: Consumer<MenuScreenController>(
        builder: (context, controller, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== FOOD IMAGE =====
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: currentFood.imageUrl.isNotEmpty
                        ? Image.network(
                            currentFood.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              );
                            },
                          )
                        : const Center(child: Icon(Icons.fastfood, size: 50)),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== FOOD NAME =====
                Text(
                  currentFood.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // ===== CATEGORY =====
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentFood.category.toUpperCase(),
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== PRICE SECTION =====
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giá',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₫${currentFood.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== DESCRIPTION =====
                const Text(
                  'Mô tả',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      currentFood.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== FOOD ID =====
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ID Món ăn',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentFood.id,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== STATUS SECTION =====
                const Text(
                  'Trạng thái',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trạng thái bán',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: currentFood.available
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentFood.available ? 'Còn hàng' : 'Hết hàng',
                                style: TextStyle(
                                  color: currentFood.available
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        DropdownButton<bool>(
                          value: currentFood.available,
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Còn hàng'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Hết hàng'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _toggleStatus(controller);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== CREATION DATE =====
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày tạo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(currentFood.createdAt),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Cập nhật lần cuối',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(currentFood.updatedAt),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ===== ACTION BUTTONS =====
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _openEdit,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: primaryColor),
                        ),
                        child: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _deleteFood(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Xoá',
                          style: TextStyle(color: whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
