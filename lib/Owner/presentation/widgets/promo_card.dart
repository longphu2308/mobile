import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/core/models/promo_model.dart';

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined, color: primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${promo.code} • ${_getTypeText(promo.type)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Switch(
                value: promo.active,
                onChanged: (_) => onToggle(),
                activeColor: primaryColor,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Giảm ${promo.discount}%",
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Flexible(
                child: Text(
                  "Đã dùng: ${promo.usedCount}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onShowDetail,
                child: const Text('Chi tiết'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'user':
        return 'Khách hàng';
      case 'owner':
        return 'Chủ quán';
      case 'both':
        return 'Tất cả';
      default:
        return type;
    }
  }
}

// Dialog functions remain below but need updating
void showCreatePromoDialog(
  BuildContext context,
  Function(PromoModel) onCreate,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Thêm khuyến mãi mới'),
        content: const Text('Chức năng đang được cập nhật'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

void showPromoDetail(BuildContext context, PromoModel promo) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Mã: ${promo.code}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mô tả: ${promo.description}'),
              Text('Giảm: ${promo.discount}%'),
              Text('Loại: ${promo.type}'),
              Text('Đã sử dụng: ${promo.usedCount} lần'),
              Text(
                'Trạng thái: ${promo.active ? "Hoạt động" : "Không hoạt động"}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Đóng'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
