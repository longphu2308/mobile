// lib/staff/screens/dashboard_screen.dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primaryColor = Color(0xFFFF6B1D);
  static const double cardRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary row
            Row(
              children: const [
                _SummaryCard(title: 'Today Orders', value: '12'),
                SizedBox(width: 12),
                _SummaryCard(title: 'Revenue', value: '₫ 2,300,000'),
              ],
            ),

            const SizedBox(height: 16),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(
                  label: 'Orders',
                  icon: Icons.receipt_long,
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                _ActionButton(
                  label: 'Menu',
                  icon: Icons.restaurant_menu,
                  onTap: () => Navigator.pushNamed(context, '/menu'),
                ),
                _ActionButton(
                  label: 'Report',
                  icon: Icons.bar_chart,
                  onTap: () => Navigator.pushNamed(context, '/report'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent orders header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('See all', style: TextStyle(color: primaryColor)),
              ],
            ),

            const SizedBox(height: 12),

            // Recent orders list
            Expanded(
              child: ListView(
                children: const [
                  _OrderTile(
                    id: 'ORD001',
                    name: 'Veggie tomato mix',
                    price: '₫ 19,000',
                    status: 'Waiting',
                  ),
                  _OrderTile(
                    id: 'ORD002',
                    name: 'Spicy fried rice',
                    price: '₫ 23,500',
                    status: 'Preparing',
                  ),
                  _OrderTile(
                    id: 'ORD003',
                    name: 'Fish with orange',
                    price: '₫ 19,000',
                    status: 'Delivered',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 98,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DashboardScreen.cardRadius),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: DashboardScreen.primaryColor),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final String id;
  final String name;
  final String price;
  final String status;
  const _OrderTile({required this.id, required this.name, required this.price, required this.status});

  Color _statusColor() {
    switch (status) {
      case 'Waiting':
        return Colors.orange;
      case 'Preparing':
        return Colors.deepOrange;
      case 'Delivered':
        return Colors.green;
      case 'Canceled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,2))],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 26, backgroundColor: Colors.grey.shade100, child: const Icon(Icons.fastfood, color: Colors.orange)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(id, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ]),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(color: _statusColor(), fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
