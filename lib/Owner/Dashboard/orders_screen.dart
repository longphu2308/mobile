// lib/staff/screens/orders_screen.dart
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Map<String, dynamic>> _orders = [
    {'id': 'ORD001', 'name': 'Veggie tomato mix', 'price': 19000, 'status': 'Waiting'},
    {'id': 'ORD002', 'name': 'Spicy fried rice', 'price': 23500, 'status': 'Preparing'},
    {'id': 'ORD003', 'name': 'Fish with orange', 'price': 19000, 'status': 'Delivered'},
  ];

  void _updateStatus(int index) {
    setState(() {
      final current = _orders[index]['status'];
      if (current == 'Waiting') _orders[index]['status'] = 'Preparing';
      else if (current == 'Preparing') _orders[index]['status'] = 'Delivered';
      else if (current == 'Delivered') _orders[index]['status'] = 'Completed';
    });
  }

  void _cancelOrder(int index) {
    setState(() {
      _orders[index]['status'] = 'Canceled';
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B1D);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Orders', style: TextStyle(color: Colors.black)),
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: _orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final o = _orders[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: Colors.grey.shade100, child: const Icon(Icons.fastfood, color: primaryColor)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(o['name'], style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text('₫ ${o['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Chip(label: Text(o['status']), backgroundColor: Colors.grey.shade100),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _updateStatus(index),
                        child: const Text('Next status'),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _cancelOrder(index),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
