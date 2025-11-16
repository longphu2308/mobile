import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

class PromoCard extends StatelessWidget {
  final Map<String, dynamic> promo;
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
                  '${promo['code']} • ${promo['type']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Switch(
                value: promo['active'],
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
              if (promo['type'] != 'Miễn phí vận chuyển')
                Flexible(
                  child: Text(
                    "Giảm ${promo['value']}% (tối đa ₫${promo['maxDiscount']})",
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              Flexible(
                child: Text(
                  "Đã dùng: ${promo['used']}",
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
}

void showPromoDetail(BuildContext context, Map<String, dynamic> promo) {
  showModalBottomSheet(
    context: context,
    backgroundColor: whiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chi tiết chương trình",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("Mã: ${promo['code']}"),
          Text("Loại: ${promo['type']}"),
          if (promo['type'] != 'Miễn phí vận chuyển')
            Text("Giá trị giảm: ${promo['value']}%"),
          if (promo['maxDiscount'] > 0)
            Text("Giảm tối đa: ₫${promo['maxDiscount']}"),
          const SizedBox(height: 10),
          Text("Đã sử dụng: ${promo['used']} lượt"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.insights),
            label: const Text('Xem báo cáo hiệu quả'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          ),
        ],
      ),
    ),
  );
}

void showCreatePromoDialog(
  BuildContext context,
  Function(Map<String, dynamic>) onCreate,
) {
  final codeCtrl = TextEditingController();
  final valueCtrl = TextEditingController();
  final maxCtrl = TextEditingController();
  String selectedType = 'Giảm %';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        title: const Text('Tạo chương trình mới'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã khuyến mãi'),
              ),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Loại khuyến mãi'),
                items: const [
                  DropdownMenuItem(value: 'Giảm %', child: Text('Giảm %')),
                  DropdownMenuItem(
                    value: 'Miễn phí vận chuyển',
                    child: Text('Miễn phí vận chuyển'),
                  ),
                  DropdownMenuItem(
                    value: 'Chiến dịch',
                    child: Text('Chiến dịch đặc biệt'),
                  ),
                ],
                onChanged: (val) => selectedType = val ?? 'Giảm %',
              ),
              TextField(
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá trị giảm (%)',
                ),
              ),
              TextField(
                controller: maxCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giảm tối đa (VND)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Tạo'),
            onPressed: () {
              final promo = {
                'code': codeCtrl.text.isNotEmpty
                    ? codeCtrl.text
                    : 'NEW${DateTime.now().millisecondsSinceEpoch}',
                'type': selectedType,
                'value': int.tryParse(valueCtrl.text) ?? 5,
                'maxDiscount': int.tryParse(maxCtrl.text) ?? 10000,
                'active': true,
                'used': 0,
              };
              onCreate(promo);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
