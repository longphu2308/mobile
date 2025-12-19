import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/core/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onUpdateStatus;
  final VoidCallback onCancel;
  final VoidCallback onShowDetail;
  final Color statusColor;

  const OrderCard({
    super.key,
    required this.order,
    required this.onUpdateStatus,
    required this.onCancel,
    required this.onShowDetail,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1),
                child: const Icon(Icons.receipt_long, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đơn hàng #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                "₫${order.totalAmount}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(
                  _getStatusText(order.status),
                  style: const TextStyle(color: whiteColor),
                ),
                backgroundColor: statusColor,
              ),
              const Spacer(),
              TextButton(
                onPressed: onShowDetail,
                child: const Text("Xem chi tiết"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.status == OrderStatus.pending) ...[
            Row(
              children: [
                ElevatedButton(
                  onPressed: onUpdateStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Chấp nhận"),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    "Từ chối",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ] else if (order.status != OrderStatus.cancelled &&
              order.status != OrderStatus.delivered) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onUpdateStatus,
                child: const Text("Cập nhật trạng thái ➜"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    return status.displayName;
  }
}

void showOrderDetail(BuildContext context, Map<String, dynamic> order) {
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
            "Chi tiết đơn ${order['id']}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text("Món: ${order['name']}"),
          Text("Giá: ₫${order['price']}"),
          Text("Ghi chú: ${order['note']}"),
          const SizedBox(height: 20),
          if (order['status'] == 'Hoàn tất')
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.replay_circle_filled),
              label: const Text('Xử lý hoàn tiền / khiếu nại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
        ],
      ),
    ),
  );
}
