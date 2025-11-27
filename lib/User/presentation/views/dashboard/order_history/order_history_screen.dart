import 'package:flutter/material.dart';
import 'package:mobile/User/presentation/controllers/order_controller.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  String _formatPrice(double price) {
    final priceStr = price.toStringAsFixed(0);
    if (priceStr.length > 3) {
      return priceStr.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return priceStr;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgColor,
        title: const Text(
          'Order History',
          style: TextStyle(color: blackColor, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Consumer<OrderController>(
        builder: (context, orderController, child) {
          if (orderController.orders.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            itemCount: orderController.orders.length,
            itemBuilder: (context, index) {
              final order = orderController.orders[index];
              return _OrderCard(
                order: order,
                formatPrice: _formatPrice,
                formatDate: _formatDate,
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String Function(double) formatPrice;
  final String Function(DateTime) formatDate;

  const _OrderCard({
    required this.order,
    required this.formatPrice,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.length >= 6 ? order.id.substring(order.id.length - 6) : order.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                ),
              ),
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatDate(order.createdAt),
            style: TextStyle(fontSize: 14, color: greyColor),
          ),
          const SizedBox(height: 16),

          // Order items grouped by restaurant
          ..._buildGroupedItems(order.items, formatPrice),

          const Divider(height: 24),

          // Total price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                formatPrice(order.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedItems(
    List<OrderItemModel> items,
    String Function(double) formatPrice,
  ) {
    // OrderItemModel doesn't have restaurant grouping, show all items
    final List<Widget> widgets = [];

    widgets.addAll(
      items.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fastfood, color: Colors.grey[600], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.foodName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'x${item.quantity}',
                style: TextStyle(fontSize: 14, color: greyColor),
              ),
              const SizedBox(width: 8),
              Text(
                formatPrice(item.price * item.quantity),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return widgets;
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending confirmation';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'delivering':
        return 'Out for delivery';
      case 'delivered':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFB347);
      case 'confirmed':
      case 'preparing':
        return primaryColor;
      case 'delivering':
        return const Color(0xFF2EC4B6);
      case 'delivered':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return primaryColor;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  static Color _getColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFB347);
      case 'confirmed':
      case 'preparing':
        return primaryColor;
      case 'delivering':
        return const Color(0xFF2EC4B6);
      case 'delivered':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return primaryColor;
    }
  }

  static String _getLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending confirmation';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing order';
      case 'delivering':
        return 'On the way';
      case 'delivered':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'No orders yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start ordering and your history will appear here.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
