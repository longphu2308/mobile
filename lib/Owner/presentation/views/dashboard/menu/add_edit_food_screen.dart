import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile/core/models/food_model.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Owner/presentation/controllers/menu_controller.dart';
import 'package:mobile/core/services/supabase/storage_service.dart';
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
  late TextEditingController discountPriceController;

  String selectedCategory = 'main';
  bool isAvailable = true;
  bool isLoading = false;
  bool isUploading = false;

  // Image handling
  File? _selectedImageFile;
  String? _imageUrl;

  final ImagePicker _imagePicker = ImagePicker();
  final StorageService _storageService = StorageService();

  // Categories list - use keys from controller
  final List<String> categoryKeys = [
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
    discountPriceController = TextEditingController();
    selectedCategory = widget.food?.category ?? 'main';
    isAvailable = widget.food?.available ?? true;
    _imageUrl = widget.food?.imageUrl;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    super.dispose();
  }

  /// Show image source selection
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn nguồn hình ảnh',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 30, color: primaryColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// Request permission for camera or photos
  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // For gallery, request photos permission
      permission = Permission.photos;
    }

    // Check current status
    var status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Request permission
      status = await permission.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      if (mounted) {
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Cần cấp quyền'),
            content: Text(
              source == ImageSource.camera
                  ? 'Ứng dụng cần quyền truy cập Camera. Vui lòng cấp quyền trong Cài đặt.'
                  : 'Ứng dụng cần quyền truy cập Thư viện ảnh. Vui lòng cấp quyền trong Cài đặt.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Mở Cài đặt'),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          await openAppSettings();
        }
      }
      return false;
    }

    return status.isGranted;
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permission first
      final hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera
                    ? 'Không có quyền truy cập Camera'
                    : 'Không có quyền truy cập Thư viện ảnh',
              ),
            ),
          );
        }
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Check file size (max 50MB)
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        const maxSize = 50 * 1024 * 1024; // 50MB

        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File quá lớn. Giới hạn 50MB.')),
            );
          }
          return;
        }

        setState(() {
          _selectedImageFile = file;
        });
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn hình ảnh: $e')));
      }
    }
  }

  /// Upload selected image to Supabase
  Future<String?> _uploadImage() async {
    if (_selectedImageFile == null) {
      return _imageUrl; // Return existing URL if no new image selected
    }

    setState(() => isUploading = true);

    try {
      final fileName = _selectedImageFile!.path.split('/').last;
      final uploadedUrl = await _storageService.uploadFoodImage(
        _selectedImageFile!,
        fileName,
      );

      if (uploadedUrl != null) {
        setState(() {
          _imageUrl = uploadedUrl;
        });
        return uploadedUrl;
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi upload hình ảnh: $e')));
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  Future<void> _saveFood() async {
    // Validate required fields
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên món ăn')));
      return;
    }

    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mô tả')));
      return;
    }

    if (priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập giá')));
      return;
    }

    // Check if we have an image (either new or existing)
    if (_selectedImageFile == null &&
        (_imageUrl == null || _imageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hình ảnh món ăn')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Upload image if new one is selected
      String? finalImageUrl = _imageUrl;
      if (_selectedImageFile != null) {
        finalImageUrl = await _uploadImage();
        if (finalImageUrl == null) {
          setState(() => isLoading = false);
          return;
        }
      }

      final controller = Get.find<MenuScreenController>();
      final price = double.parse(priceController.text);

      final food = FoodModel(
        id: widget.food?.id ?? '',
        restaurantId:
            widget.restaurantId ??
            widget.food?.restaurantId ??
            controller.restaurant?.id ??
            '',
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: price,
        imageUrl: finalImageUrl ?? '',
        category: selectedCategory,
        available: isAvailable,
        createdAt: widget.food?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.food == null) {
        // Add new food
        final success = await controller.addItem(food);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm món ăn thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        // Update existing food
        final success = await controller.updateItem(widget.food!.id, food);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật món ăn thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, food);
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
        elevation: 0,
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
            // ===== IMAGE SECTION =====
            const Text(
              'Hình ảnh món ăn *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: isLoading || isUploading ? null : _showImageSourceDialog,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn để chọn hình ảnh từ camera hoặc thư viện (tối đa 50MB)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),

            const SizedBox(height: 24),

            // ===== FOOD NAME =====
            const Text(
              'Tên món ăn *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Phở bò tái',
                filled: true,
                fillColor: whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
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
                hintText: 'Mô tả chi tiết về món ăn...',
                filled: true,
                fillColor: whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== PRICE ROW =====
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá bán *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixText: '₫ ',
                          prefixStyle: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: whiteColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giá giảm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: discountPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Tuỳ chọn',
                          prefixText: '₫ ',
                          prefixStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: whiteColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== CATEGORY =====
            const Text(
              'Danh mục *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(12),
                  items: categoryKeys.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(MenuScreenController.getCategoryLabel(cat)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== STATUS =====
            const Text(
              'Trạng thái',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isAvailable = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.withValues(alpha: 0.1)
                            : whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAvailable
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: isAvailable ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: isAvailable ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Còn hàng',
                            style: TextStyle(
                              color: isAvailable ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isAvailable = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !isAvailable
                            ? Colors.red.withValues(alpha: 0.1)
                            : whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !isAvailable
                              ? Colors.red
                              : Colors.grey.shade300,
                          width: !isAvailable ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 20,
                            color: !isAvailable ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hết hàng',
                            style: TextStyle(
                              color: !isAvailable ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ===== SAVE BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading || isUploading ? null : _saveFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading || isUploading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                whiteColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isUploading ? 'Đang tải ảnh...' : 'Đang lưu...',
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  /// Build image preview widget
  Widget _buildImagePreview() {
    if (isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 12),
            Text('Đang tải ảnh...'),
          ],
        ),
      );
    }

    if (_selectedImageFile != null) {
      // Show selected local file
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImageFile = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Ảnh mới',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    }

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      // Show existing image from URL
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: primaryColor,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Lỗi tải ảnh'),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Đổi ảnh',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Show placeholder
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          'Nhấn để chọn hình ảnh',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }
}
