import 'package:flutter/material.dart';
import 'package:mobile/User/domain/models/order.dart';
import 'package:mobile/User/domain/models/cart_item.dart';
import 'package:mobile/core/services/order/order_service.dart';
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
          'Lịch sử đơn hàng',
          style: TextStyle(color: blackColor),
        ),
        centerTitle: true,
      ),
      body: Consumer<OrderService>(
        builder: (context, orderService, child) {
          if (orderService.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có đơn hàng nào',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            itemCount: orderService.orders.length,
            itemBuilder: (context, index) {
              final order = orderService.orders[index];
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
  final Order order;
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
                'Đơn hàng #${order.id.length >= 6 ? order.id.substring(order.id.length - 6) : order.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status == 'completed' ? 'Hoàn thành' : order.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatDate(order.createdAt),
            style: TextStyle(
              fontSize: 14,
              color: greyColor,
            ),
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
                'Tổng tiền:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatPrice(order.totalPrice),
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

  List<Widget> _buildGroupedItems(List<CartItem> items, String Function(double) formatPrice) {
    // Group items by restaurant
    final Map<String, List<CartItem>> grouped = {};
    for (var item in items) {
      final restaurantName = item.food.restaurantName;
      if (!grouped.containsKey(restaurantName)) {
        grouped[restaurantName] = [];
      }
      grouped[restaurantName]!.add(item);
    }

    final List<Widget> widgets = [];
    grouped.forEach((restaurantName, restaurantItems) {
      // Restaurant header if multiple restaurants
      if (grouped.length > 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.store,
                  size: 14,
                  color: primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  restaurantName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: greyColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      // Items from this restaurant
      widgets.addAll(
        restaurantItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  item.food.assetSrc,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.food.name,
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
                style: TextStyle(
                  fontSize: 14,
                  color: greyColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatPrice(item.totalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        )),
      );
    });

    return widgets;
  }
}

