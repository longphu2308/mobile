import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/core/models/promo_model.dart';
import 'package:mobile/config/routes.dart';

class PromoCard extends StatelessWidget {
  final PromoModel promo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onShowDetail;

  const PromoCard({
    super.key,
    required this.promo,
    required this.onToggle,
    required this.onDelete,
    required this.onShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onShowDetail,
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: promo.active
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: promo.active
                    ? Colors.green.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Voucher icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: primaryColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Code & Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promo.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: promo.active
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          promo.active ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: promo.active ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          promo.active ? 'Hoạt động' : 'Tắt',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: promo.active ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== BODY =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Discount info row
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.percent,
                        label: 'Giảm ${promo.discountPercent.toStringAsFixed(0)}%',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Tối thiểu ${_formatMoney(promo.minOrderAmount)}',
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Time & Usage row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoBox(
                          icon: Icons.calendar_today_outlined,
                          title: 'Thời gian',
                          value:
                              '${_formatDate(promo.startDate)} - ${_formatDate(promo.endDate)}',
                          color: promo.isExpired ? Colors.red : Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoBox(
                          icon: Icons.confirmation_number_outlined,
                          title: 'Lượt dùng',
                          value: '${promo.usedCount}/${promo.usageLimit}',
                          color: promo.isUsageLimitReached
                              ? Colors.orange
                              : Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Usage progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: promo.usageLimit > 0
                              ? promo.usedCount / promo.usageLimit
                              : 0,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            promo.isUsageLimitReached
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${((promo.usedCount / (promo.usageLimit > 0 ? promo.usageLimit : 1)) * 100).toStringAsFixed(0)}% đã sử dụng',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Còn ${promo.usageLimit - promo.usedCount} lượt',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ===== FOOTER ACTIONS =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Toggle button - Full width for better UX
                  Expanded(
                    child: InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: promo.active
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: promo.active
                                ? Colors.orange.withOpacity(0.3)
                                : Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              promo.active
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              color: promo.active ? Colors.orange : Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              promo.active ? 'Tạm ngưng' : 'Kích hoạt',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    promo.active ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete button
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

// Navigation functions
void showCreatePromoDialog(
  BuildContext context,
  Function(PromoModel) onCreate, {
  String? restaurantId,
}) {
  Navigator.pushNamed(
    context,
    ownerAddEditPromoRoute,
    arguments: {'restaurantId': restaurantId},
  );
}

void showPromoDetail(BuildContext context, PromoModel promo) {
  Navigator.pushNamed(
    context,
    ownerPromoDetailRoute,
    arguments: {'promo': promo},
  );
}
