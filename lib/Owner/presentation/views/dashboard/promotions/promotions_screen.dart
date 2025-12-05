import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/promotions_controller.dart';
import 'package:mobile/Owner/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Owner/presentation/views/dashboard/promotions/add_edit_promo_screen.dart';
import 'package:provider/provider.dart';

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
    _controller = PromotionsController();
    _controller.loadPromos();
  }

  void _createPromo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _controller,
          child: const AddEditPromoScreen(),
        ),
      ),
    ).then((_) {
      _controller.loadPromos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<PromotionsController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: whiteColor,
              title: const Text(
                'Chương trình khuyến mãi',
                style: TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: BackButton(color: blackColor),
              actions: [
                IconButton(
                  onPressed: _createPromo,
                  icon: const Icon(Icons.add, color: primaryColor),
                ),
              ],
            ),
            body: ListView.separated(
              padding: const EdgeInsets.all(horizontalPadding),
              itemCount: controller.promos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final promo = controller.promos[idx];
                return PromoCard(
                  promo: promo,
                  onToggle: () =>
                      controller.toggleActive(promo.id, !promo.active),
                  onDelete: () => controller.deletePromo(promo.id),
                  onShowDetail: () => showPromoDetail(context, promo),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
