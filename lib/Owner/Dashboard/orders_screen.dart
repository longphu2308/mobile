import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD001',
      'name': 'Cơm gà chiên giòn',
      'price': 45000,
      'status': 'Chờ xác nhận',
      'note': 'Không cay, thêm tương ớt'
    },
    {
      'id': 'ORD002',
      'name': 'Bún bò Huế',
      'price': 50000,
      'status': 'Đang chuẩn bị',
      'note': 'Ít hành lá'
    },
    {
      'id': 'ORD003',
      'name': 'Trà đào cam sả',
      'price': 30000,
      'status': 'Đang giao',
      'note': 'Giao cho tài xế A123'
    },
    {
      'id': 'ORD004',
      'name': 'Cơm chiên hải sản',
      'price': 55000,
      'status': 'Hoàn tất',
      'note': 'Khách thanh toán tiền mặt'
    },
    {
      'id': 'ORD005',
      'name': 'Mì xào bò',
      'price': 42000,
      'status': 'Đã hủy',
      'note': 'Khách hủy đơn'
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đang chuẩn bị':
        return Colors.blue;
      case 'Đang giao':
        return Colors.purple;
      case 'Hoàn tất':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateStatus(int index) {
    setState(() {
      final current = _orders[index]['status'];
      switch (current) {
        case 'Chờ xác nhận':
          _orders[index]['status'] = 'Đang chuẩn bị';
          break;
        case 'Đang chuẩn bị':
          _orders[index]['status'] = 'Đang giao';
          break;
        case 'Đang giao':
          _orders[index]['status'] = 'Hoàn tất';
          break;
        default:
          break;
      }
    });
  }

  void _cancelOrder(int index) {
    setState(() {
      _orders[index]['status'] = 'Đã hủy';
    });
  }

  void _showOrderDetail(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chi tiết đơn ${order['id']}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B1D);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Quản lý đơn hàng',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: BackButton(color: Colors.black),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      child: const Icon(Icons.receipt_long,
                          color: primaryColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(order['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                    Text("₫${order['price']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(order['status'],
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: _statusColor(order['status']),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showOrderDetail(order),
                      child: const Text("Xem chi tiết"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (order['status'] == 'Chờ xác nhận') ...[
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateStatus(index),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text("Chấp nhận"),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _cancelOrder(index),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red)),
                        child: const Text("Từ chối",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                ] else if (order['status'] != 'Đã hủy' &&
                    order['status'] != 'Hoàn tất') ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _updateStatus(index),
                      child: const Text("Cập nhật trạng thái ➜"),
                    ),
                  )
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
