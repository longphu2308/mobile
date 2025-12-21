import 'package:flutter/material.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Owner/presentation/controllers/menu_controller.dart';
import 'package:get/get.dart';

class AddEditFoodScreen extends StatefulWidget {
  final FoodModel? food;
  final String? restaurantId;

  const AddEditFoodScreen({super.key, this.food, this.restaurantId});

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController imageUrlController;
  late TextEditingController discountPriceController;
  String selectedCategory = 'main';
  bool isAvailable = true;
  bool isLoading = false;

  final List<String> categories = [
    'main',
    'appetizer',
    'dessert',
    'drink',
    'combo',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.food?.name ?? '');
    descriptionController = TextEditingController(
      text: widget.food?.description ?? '',
    );
    priceController = TextEditingController(
      text: widget.food?.price.toString() ?? '',
    );
    imageUrlController = TextEditingController(
      text: widget.food?.imageUrl ?? '',
    );
    discountPriceController = TextEditingController();
    selectedCategory = widget.food?.category ?? 'main';
    isAvailable = widget.food?.available ?? true;

    // Add listener for image preview update
    imageUrlController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    discountPriceController.dispose();
    super.dispose();
  }

  /// Validate image URL
  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn nguồn hình ảnh'),
        content: const Text('Vui lòng chọn URL hình ảnh từ:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showImageUrlInputDialog();
            },
            child: const Text('Nhập URL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng camera sẽ được thêm sau'),
                ),
              );
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng thư viện sẽ được thêm sau'),
                ),
              );
            },
            child: const Text('Thư viện'),
          ),
        ],
      ),
    );
  }

  /// Show image URL input dialog
  void _showImageUrlInputDialog() {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nhập URL hình ảnh'),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập URL')),
                );
                return;
              }

              if (!_isValidImageUrl(urlController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL không hợp lệ')),
                );
                return;
              }

              imageUrlController.text = urlController.text;
              Navigator.pop(context);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hình ảnh đã cập nhật')),
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  /// Upload image (placeholder for future Firebase implementation)
  Future<void> _uploadImage() async {
    _showImageSourceDialog();
  }

  Future<void> _savFood() async {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        imageUrlController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền tất cả thông tin')),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      final controller = Get.find<MenuScreenController>();
      final price = double.parse(priceController.text);

      final food = FoodModel(
        id: widget.food?.id ?? '',
        restaurantId:
            widget.restaurantId ??
            widget.food?.restaurantId ??
            controller.restaurant?.id ??
            '',
        name: nameController.text,
        description: descriptionController.text,
        price: price,
        imageUrl: imageUrlController.text,
        category: selectedCategory,
        available: isAvailable,
        createdAt: widget.food?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.food == null) {
        // Add new food
        await controller.addItem(food);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm món ăn thành công')),
          );
          Navigator.pop(context);
        }
      } else {
        // Update existing food
        await controller.updateItem(widget.food!.id, food);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật món ăn thành công')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          widget.food == null ? 'Thêm món ăn mới' : 'Chỉnh sửa món ăn',
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: blackColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== FOOD NAME =====
            const Text(
              'Tên món ăn *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Nhập tên món ăn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== DESCRIPTION =====
            const Text(
              'Mô tả *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập mô tả chi tiết',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== ORIGINAL PRICE =====
            const Text(
              'Giá gốc *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập giá gốc',
                prefixText: '₫',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== DISCOUNT PRICE =====
            const Text(
              'Giá giảm (tuỳ chọn)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: discountPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập giá sau khi giảm (nếu có)',
                prefixText: '₫',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== IMAGE URL =====
            const Text(
              'Hình ảnh *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      hintText: 'Nhập URL hình ảnh',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _uploadImage,
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Preview hình ảnh
            if (imageUrlController.text.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('Lỗi tải hình ảnh'));
                    },
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ===== CATEGORY =====
            const Text(
              'Danh mục *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCategory = value);
                }
              },
            ),

            const SizedBox(height: 20),

            // ===== STATUS =====
            const Text(
              'Trạng thái',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<bool>(
                  value: isAvailable,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Còn hàng')),
                    DropdownMenuItem(value: false, child: Text('Hết hàng')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => isAvailable = value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ===== SAVE BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _savFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                        ),
                      )
                    : Text(
                        widget.food == null ? 'Thêm món ăn' : 'Lưu thay đổi',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
