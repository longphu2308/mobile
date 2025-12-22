import 'package:flutter/material.dart';
import 'package:mobile/core/models/promo_model.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Owner/presentation/controllers/promotions_controller.dart';
import 'package:get/get.dart';

class AddEditPromoScreen extends StatefulWidget {
  final PromoModel? promo;
  final String? restaurantId;

  const AddEditPromoScreen({super.key, this.promo, this.restaurantId});

  @override
  State<AddEditPromoScreen> createState() => _AddEditPromoScreenState();
}

class _AddEditPromoScreenState extends State<AddEditPromoScreen> {
  late TextEditingController codeController;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController discountController;
  late TextEditingController maxDiscountController;
  late TextEditingController minOrderController;
  late TextEditingController usageLimitController;
  DateTime? startDate;
  DateTime? endDate;
  bool isActive = true;
  bool isLoading = false;
  String selectedType = 'order'; // Loại voucher: order, delivery, food, all

  // Danh sách các loại voucher hợp lệ theo DB constraint
  static const List<String> _validTypes = ['delivery', 'food', 'both'];

  // Đảm bảo selectedType luôn hợp lệ cho dropdown
  String _getValidSelectedType() {
    if (_validTypes.contains(selectedType)) {
      return selectedType;
    }
    // Nếu type không hợp lệ, mặc định là 'delivery'
    return 'delivery';
  }

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(text: widget.promo?.code ?? '');
    nameController = TextEditingController(text: widget.promo?.name ?? '');
    descriptionController = TextEditingController(
      text: widget.promo?.description ?? '',
    );
    discountController = TextEditingController(
      text: widget.promo?.discount.toString() ?? '',
    );
    maxDiscountController = TextEditingController(
      text: widget.promo?.maxDiscountAmount?.toString() ?? '',
    );
    minOrderController = TextEditingController(
      text: widget.promo?.minOrderAmount.toString() ?? '',
    );
    usageLimitController = TextEditingController(
      text: widget.promo?.usageLimit.toString() ?? '999',
    );
    startDate = widget.promo?.startDate;
    endDate = widget.promo?.endDate;
    isActive = widget.promo?.active ?? true;
    // Đảm bảo type hợp lệ (DB chỉ cho phép: delivery, food, both)
    final promoType = widget.promo?.type ?? 'delivery';
    selectedType = _validTypes.contains(promoType) ? promoType : 'delivery';
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    discountController.dispose();
    maxDiscountController.dispose();
    minOrderController.dispose();
    usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (startDate ?? DateTime.now())
          : (endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _savePromo() async {
    if (codeController.text.isEmpty ||
        nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        discountController.text.isEmpty ||
        minOrderController.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền tất cả thông tin')),
        );
      }
      return;
    }

    if (startDate!.isAfter(endDate!)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ngày bắt đầu phải trước ngày kết thúc'),
          ),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      final controller = Get.find<PromotionsController>();
      final discountValue = int.tryParse(discountController.text) ?? 0;

      // Get restaurantId from controller if not provided
      String? restaurantId = widget.restaurantId ?? widget.promo?.restaurantId;
      if (restaurantId == null && widget.promo == null) {
        // Get from controller for new promos
        try {
          final promoController = Get.find<PromotionsController>();
          restaurantId = promoController.restaurantId;
        } catch (e) {
          print('Error getting restaurant ID: $e');
        }
      }

      final promo = PromoModel(
        id: widget.promo?.id ?? '',
        code: codeController.text.toUpperCase(),
        description: descriptionController.text,
        discount: discountValue,
        type: selectedType,
        restaurantId: restaurantId,
        startDate: startDate!,
        endDate: endDate!,
        active: isActive,
        usedCount: widget.promo?.usedCount ?? 0,
        createdAt: widget.promo?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.promo == null) {
        await controller.addPromo(promo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm voucher thành công')),
          );
          Navigator.pop(context);
        }
      } else {
        await controller.updatePromo(widget.promo!.id, promo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật voucher thành công')),
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
          widget.promo == null ? 'Thêm voucher mới' : 'Chỉnh sửa voucher',
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
            // ===== CODE =====
            const Text(
              'Mã voucher *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: 'VD: KHUYENMAI2024',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== NAME =====
            const Text(
              'Tên voucher *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'VD: Giảm 20% cho đơn hàng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== DESCRIPTION =====
            const Text(
              'Mô tả *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập mô tả chi tiết về voucher',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== VOUCHER TYPE =====
            const Text(
              'Loại voucher',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _getValidSelectedType(),
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  // Chỉ 3 loại được phép theo DB constraint
                  DropdownMenuItem(
                    value: 'delivery',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delivery_dining,
                          size: 18,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text('🚚 Vận chuyển'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'food',
                    child: Row(
                      children: [
                        Icon(Icons.fastfood, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('🍔 Món ăn'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'both',
                    child: Row(
                      children: [
                        Icon(Icons.group, size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text('✨ Cả hai'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // ===== DISCOUNT PERCENT =====
            const Text(
              'Chiết khấu (%)*',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'VD: 20',
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== MAX DISCOUNT =====
            const Text(
              'Giới hạn giảm tối đa (tuỳ chọn)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: maxDiscountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'VD: 50000',
                prefixText: '₫',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== MIN ORDER =====
            const Text(
              'Đơn hàng tối thiểu *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: minOrderController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'VD: 100000',
                prefixText: '₫',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== USAGE LIMIT =====
            const Text(
              'Giới hạn sử dụng *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usageLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'VD: 100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== DATE RANGE =====
            const Text(
              'Thời gian áp dụng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày bắt đầu *',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectDate(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            startDate == null
                                ? 'Chọn ngày'
                                : '${startDate!.day}/${startDate!.month}/${startDate!.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày kết thúc *',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectDate(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            endDate == null
                                ? 'Chọn ngày'
                                : '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== ACTIVE STATUS =====
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trạng thái hoạt động',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                    activeColor: primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ===== SAVE BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _savePromo,
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
                        widget.promo == null ? 'Thêm voucher' : 'Lưu thay đổi',
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
