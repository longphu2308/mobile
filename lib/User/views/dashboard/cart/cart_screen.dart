import 'package:flutter/material.dart';
import 'package:mobile/User/models/cart_item.dart';
import 'package:mobile/User/services/cart_service.dart';
import 'package:mobile/User/services/order_service.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
        title: const Text(
          'Cart',
          style: TextStyle(color: blackColor),
        ),
        centerTitle: true,
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Giỏ hàng trống',
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

          final groupedItems = _groupItemsByRestaurant(cartService.items);
          final restaurantNames = groupedItems.keys.toList();

          return Column(
            children: [
              // Instruction for swipe to delete
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swipe_left,
                      size: 20,
                      color: greyColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'swipe on an item to delete',
                      style: TextStyle(
                        fontSize: 14,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Cart items list grouped by restaurant
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  itemCount: restaurantNames.length,
                  itemBuilder: (context, restaurantIndex) {
                    final restaurantName = restaurantNames[restaurantIndex];
                    final items = groupedItems[restaurantName]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant header
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 12,
                            top: restaurantIndex > 0 ? 8 : 0,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.store,
                                size: 18,
                                color: primaryColor,
                              ),
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
                        // Items in this restaurant
                        ...items.map((item) => _CartItemCard(
                          item: item,
                          onDelete: () {
                            cartService.removeItem(item.food.name);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xóa ${item.food.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          onIncrement: () {
                            cartService.incrementQuantity(item.food.name);
                          },
                          onDecrement: () {
                            cartService.decrementQuantity(item.food.name);
                          },
                          formatPrice: _formatPrice,
                        )),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),

              // Complete order button
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
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            _completeOrder(context, cartService);
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
                            'Complete order',
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

  void _completeOrder(BuildContext context, CartService cartService) {
    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giỏ hàng trống'),
        ),
      );
      return;
    }

    final orderService = Provider.of<OrderService>(context, listen: false);
    final totalPrice = cartService.totalPrice;
    final items = List<CartItem>.from(cartService.items);

    orderService.addOrder(items, totalPrice);
    cartService.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đặt hàng thành công!'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String Function(double) formatPrice;

  const _CartItemCard({
    required this.item,
    required this.onDelete,
    required this.onIncrement,
    required this.onDecrement,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.food.name),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: Container(
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
            // Food image
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
            
            // Food name and price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    formatPrice(item.food.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: whiteColor, size: 18),
                    onPressed: onDecrement,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        color: whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: whiteColor, size: 18),
                    onPressed: onIncrement,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
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

