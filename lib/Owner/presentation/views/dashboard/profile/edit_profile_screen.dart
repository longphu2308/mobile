import 'package:flutter/material.dart';
import 'package:mobile/core/models/restaurant_model.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Owner/presentation/controllers/restaurant_controller.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  final RestaurantModel? restaurant;

  const EditProfileScreen({super.key, this.restaurant});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.restaurant?.name ?? '');
    phoneController = TextEditingController(
      text: widget.restaurant?.phone ?? '',
    );
    addressController = TextEditingController(
      text: widget.restaurant?.address ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.restaurant?.description ?? '',
    );
    imageUrlController = TextEditingController(
      text: widget.restaurant?.imageUrl ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền tất cả thông tin')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final controller = Get.find<RestaurantController>();
      final currentRestaurant = widget.restaurant ?? controller.restaurant;

      if (currentRestaurant == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy thông tin quán')),
          );
        }
        return;
      }

      final updatedRestaurant = currentRestaurant.copyWith(
        name: nameController.text,
        phone: phoneController.text,
        address: addressController.text,
        description: descriptionController.text,
        imageUrl: imageUrlController.text,
      );

      await controller.updateRestaurant(updatedRestaurant);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
        Navigator.pop(context);
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
        elevation: 0,
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveProfile,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Lưu',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image URL
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    backgroundImage: imageUrlController.text.isNotEmpty
                        ? NetworkImage(imageUrlController.text)
                        : null,
                    child: imageUrlController.text.isEmpty
                        ? const Icon(Icons.store, size: 60, color: primaryColor)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryColor,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: whiteColor,
                        ),
                        onPressed: () {
                          _showImageUrlDialog();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            _buildTextField(
              controller: nameController,
              label: 'Tên quán',
              icon: Icons.store,
            ),
            const SizedBox(height: 16),

            // Phone field
            _buildTextField(
              controller: phoneController,
              label: 'Số điện thoại',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Address field
            _buildTextField(
              controller: addressController,
              label: 'Địa chỉ',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 16),

            // Description field
            _buildTextField(
              controller: descriptionController,
              label: 'Mô tả',
              icon: Icons.description,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: whiteColor,
        ),
      ),
    );
  }

  void _showImageUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập URL hình ảnh'),
        content: TextField(
          controller: imageUrlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
