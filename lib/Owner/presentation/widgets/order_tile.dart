import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/core/models/order_model.dart';

class OrderTile extends StatelessWidget {
  final String name;
  final String price;
  final OrderStatus status;
  final VoidCallback? onTap;

  const OrderTile({
    super.key,
    required this.name,
    required this.price,
    required this.status,
    this.onTap,
  });

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.indigo;
      case OrderStatus.readyForPickup:
        return Colors.teal;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: primaryColor.withValues(alpha: 0.2),
            child: const Icon(Icons.fastfood, color: primaryColor),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(price),
          trailing: Text(
            status.displayName,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
