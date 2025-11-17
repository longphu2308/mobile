import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

class OrderTile extends StatelessWidget {
  final String name;
  final String price;
  final String status;

  const OrderTile({
    super.key,
    required this.name,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (status == "Hoàn thành") {
      statusColor = Colors.green;
    } else if (status == "Đang giao") {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.2),
          child: const Icon(Icons.fastfood, color: primaryColor),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(price),
        trailing: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}