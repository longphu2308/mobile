import 'package:flutter/material.dart';
import 'package:mobile/User/state/foodie_store.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year – $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodieStore>(
      builder: (context, store, _) {
        if (store.orders.isEmpty) {
          return const _EmptyHistory();
        }
        return ListView(
          padding: const EdgeInsets.all(horizontalPadding),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử đặt hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: store.orders.isEmpty ? null : store.clearHistory,
                  child: const Text('Xóa lịch sử'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...store.orders.map((order) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.vendorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${formatCurrency(order.total)} đ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Giao hàng: ${deliveryMethodLabel(order.deliveryMethod)} · Thanh toán: ${paymentMethodLabel(order.paymentMethod)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantity} x ${item.name}'),
                              Text(
                                '${formatCurrency(item.subtotal)} đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 96,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có đơn hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Các đơn hàng bạn đã thanh toán sẽ hiển thị ở đây để dễ dàng theo dõi.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}


