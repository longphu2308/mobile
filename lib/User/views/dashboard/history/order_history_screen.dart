import 'package:flutter/material.dart';
import 'package:mobile/User/models/order.dart';
import 'package:mobile/User/providers/order_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgColor,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: blackColor,
            ),
        iconTheme: IconThemeData(
          color: blackColor,
        ),
        title: const Text('Lịch sử đặt hàng'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.orders.isEmpty) {
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
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return _buildOrderCard(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
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
          // Header với thời gian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.formattedTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_formatPrice(order.totalPrice)} đ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          // Danh sách món theo quán
          ...order.itemsByRestaurant.entries.map((entry) {
            final restaurantName = entry.key;
            final items = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên quán
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 18,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      restaurantName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: blackColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Danh sách món
                ...items.map((cartItem) => Padding(
                      padding: const EdgeInsets.only(left: 26, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '${cartItem.quantity}x ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: greyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    cartItem.food.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_formatPrice(cartItem.totalPrice)} đ',
                            style: TextStyle(
                              fontSize: 14,
                              color: greyColor,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (entry.key != order.itemsByRestaurant.keys.last)
                  const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }
}

