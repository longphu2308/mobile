import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';

class ShipperProfile extends StatelessWidget {
  static const routeName = '/shipper/profile';
  const ShipperProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final recent = ShipperOrder.mockOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 44,
                child: Icon(Icons.person, size: 44),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Người giao hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            const Center(child: Text('Vehicle: Motorbike • Plate: 79A-000.00')),
            const SizedBox(height: 12),

            // Vertical action buttons (full width, consistent height)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Chỉnh sửa thông tin'),
                          content: const Text('Mock edit form goes here.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    child: const Text('Chỉnh sửa'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, authRoute, (route) => false),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    child: const Text('Đăng xuất'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          final _oldCtrl = TextEditingController();
                          final _newCtrl = TextEditingController();
                          final _confirmCtrl = TextEditingController();
                          return StatefulBuilder(builder: (c, setState) {
                            return AlertDialog(
                              title: const Text('Đổi mật khẩu'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(controller: _oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu cũ')),
                                  TextField(controller: _newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu mới')),
                                  TextField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới')),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                  onPressed: () {
                                    final old = _oldCtrl.text.trim();
                                    final nw = _newCtrl.text.trim();
                                    final cf = _confirmCtrl.text.trim();
                                    if (nw.isEmpty || cf.isEmpty || old.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin')));
                                      return;
                                    }
                                    if (nw != cf) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu mới và xác nhận không khớp')));
                                      return;
                                    }
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu đã được đổi (mock)')));
                                  },
                                  child: const Text('Lưu'),
                                ),
                              ],
                            );
                          });
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    child: const Text('Đổi mật khẩu'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Mock stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard('Rating', '4.8', Icons.star, Colors.amber),
                _statCard('Completed', '124', Icons.check_circle, Colors.green),
                _statCard(
                  'Earnings',
                  '12,500,000',
                  Icons.attach_money,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'Recent deliveries',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Column(
              children: recent.map((r) {
                return Card(
                  child: ListTile(
                    title: Text('${r.id} • ${r.customerName}'),
                    subtitle: Text('${r.address}'),
                    trailing: Text('${r.total.toInt()} VND'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/shipper/order-detail',
                      arguments: r,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
