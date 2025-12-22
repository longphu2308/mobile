import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/Owner/presentation/controllers/promotions_controller.dart';
import 'package:mobile/Owner/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Owner/presentation/views/dashboard/promotions/add_edit_promo_screen.dart';
import 'package:mobile/core/models/promo_model.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  late PromotionsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(PromotionsController());
    _controller.loadPromos();
  }

  void _createPromo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditPromoScreen()),
    ).then((_) {
      _controller.loadPromos();
    });
  }

  Future<void> _confirmDelete(PromoModel promo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá voucher?'),
        content: Text('Bạn có chắc muốn xoá voucher "${promo.code}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.deletePromo(promo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Chương trình khuyến mãi',
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _controller.loadPromos(),
            icon: const Icon(Icons.refresh, color: Colors.grey),
          ),
          IconButton(
            onPressed: _createPromo,
            icon: const Icon(Icons.add_circle, color: primaryColor, size: 28),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.promos.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _controller.loadPromos(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.promos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final promo = _controller.promos[idx];
              return PromoCard(
                promo: promo,
                onToggle: () =>
                    _controller.toggleActive(promo.id, !promo.active),
                onDelete: () => _confirmDelete(promo),
                onShowDetail: () => showPromoDetail(context, promo),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có voucher nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tạo voucher để thu hút khách hàng',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createPromo,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tạo voucher đầu tiên',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
