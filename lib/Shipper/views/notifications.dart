import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Shipper/widgets/shipper_bottom_nav.dart';

class NotificationsPage extends StatefulWidget {
  static const routeName = '/shipper/notifications';
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _items = [
    {'title': 'Đơn hàng mới SO-1001', 'time': '2m', 'read': false},
    {'title': 'Chính sách mới', 'time': '1d', 'read': false},
    {'title': 'Thưởng 50k', 'time': '3d', 'read': true},
  ];

  void _markAllRead() {
    setState(() {
      for (var it in _items) {
        it['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Đã đọc tất cả',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        itemBuilder: (ctx, i) {
          final it = _items[i];
          return Card(
            color: it['read'] ? Colors.white : bgColor,
            child: ListTile(
              title: Text(it['title']),
              subtitle: Text(it['time']),
              onTap: () {},
            ),
          );
        },
      ),
      bottomNavigationBar: shipperBottomNav(context, 0),
    );
  }
}
