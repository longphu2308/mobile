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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: promo.active
                ? primaryColor.withValues(alpha: 0.2)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== CODE & NAME =====
            Row(
              children: [
                const Icon(
                  Icons.local_offer_outlined,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        promo.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: promo.active
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    promo.active ? 'Hoạt động' : 'Tắt',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: promo.active ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ===== DESCRIPTION =====
            if (promo.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  promo.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // ===== DISCOUNT & CONDITIONS =====
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giảm',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${promo.discountPercent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đơn tối thiểu',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₫${(promo.minOrderAmount / 1000).toStringAsFixed(0)}K',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (promo.maxDiscountAmount != null &&
                      promo.maxDiscountAmount! > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tối đa',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₫${(promo.maxDiscountAmount! / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ===== TIME & USAGE INFO =====
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thời gian áp dụng',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: promo.isExpired
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${promo.startDate.day}/${promo.startDate.month} - ${promo.endDate.day}/${promo.endDate.month}/${promo.endDate.year}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: promo.isExpired ? Colors.red : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lượt sử dụng',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: promo.isUsageLimitReached
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${promo.usedCount}/${promo.usageLimit}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: promo.isUsageLimitReached
                              ? Colors.orange
                              : Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ===== USAGE PROGRESS BAR =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: promo.usedCount / promo.usageLimit,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      promo.isUsageLimitReached ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${((promo.usedCount / promo.usageLimit) * 100).toStringAsFixed(0)}% đã sử dụng',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Còn ${promo.usageLimit - promo.usedCount} lượt',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    promo.active
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: promo.active ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: promo.active ? 'Tắt' : 'Bật',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'Xoá',
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
