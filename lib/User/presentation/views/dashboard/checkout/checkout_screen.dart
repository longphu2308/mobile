import 'package:flutter/material.dart';
import 'package:mobile/User/domain/models/cart_item.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/order_controller.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/formatters.dart';
import 'package:mobile/config/routes.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  Map<String, List<CartItem>> _groupItemsByRestaurant(List<CartItem> items) {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in items) {
      final restaurantName = item.food.restaurantName;
      if (!grouped.containsKey(restaurantName)) {
        grouped[restaurantName] = [];
      }
      grouped[restaurantName]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thanh toán', style: TextStyle(color: blackColor)),
        centerTitle: true,
      ),
      body: Consumer<CartController>(
        builder: (context, cartController, child) {
          if (cartController.items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          final groupedItems = _groupItemsByRestaurant(cartController.items);
          final restaurantNames = groupedItems.keys.toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(horizontalPadding),
                  itemCount: restaurantNames.length,
                  itemBuilder: (context, restaurantIndex) {
                    final restaurantName = restaurantNames[restaurantIndex];
                    final items = groupedItems[restaurantName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.store, size: 18, color: primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                restaurantName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...items.map(
                          (item) => Container(
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
                            child: Row(
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    item.food.assetSrc,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.food.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: blackColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ' x ',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatPrice(item.totalPrice),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(horizontalPadding),
                decoration: BoxDecoration(
                  color: whiteColor,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: blackColor,
                            ),
                          ),
                          Text(
                            formatPrice(cartController.totalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            _completeOrder(context, cartController);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Complete Order',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _completeOrder(BuildContext context, CartController cartController) {
    final orderController = Provider.of<OrderController>(
      context,
      listen: false,
    );
    final totalPrice = cartController.totalPrice;
    final items = List<CartItem>.from(cartController.items);

    print('Starting order creation with ${items.length} items, total: $totalPrice');

    // Create order and handle the result
    orderController.createOrder(items, totalPrice).then((success) {
      print('Order creation result: $success');
      
      if (!context.mounted) return; // Check if context is still valid
      
      if (success) {
        print('Order successful, clearing cart');
        // Clear cart after successful order
        cartController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );

        // Navigate to order history
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            orderHistoryRoute,
            (route) => route.settings.name == dashboardRoute,
          );
        }
      } else {
        // Show error if order creation failed
        print('Order failed: ${orderController.errorMessage}');
        print('Order state: ${orderController.state}');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                orderController.errorMessage ?? 'Lỗi đặt hàng. Vui lòng thử lại.',
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}
