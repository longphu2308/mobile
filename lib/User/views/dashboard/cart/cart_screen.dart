import 'package:flutter/material.dart';
import 'package:mobile/User/models/cart_item.dart';
import 'package:mobile/User/providers/cart_provider.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/User/views/widgets/widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgColor,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: blackColor,
            ),
        iconTheme: IconThemeData(
          color: blackColor,
        ),
        title: Text(FoodieStrings.cart),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
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
                    FoodieStrings.emptyCart,
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

          final itemsByRestaurant = cartProvider.itemsByRestaurant;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemCount: itemsByRestaurant.length,
                  itemBuilder: (context, restaurantIndex) {
                    final restaurantName = itemsByRestaurant.keys.elementAt(restaurantIndex);
                    final items = itemsByRestaurant[restaurantName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant name header
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                restaurantName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Items from this restaurant
                        ...items.map((cartItem) => _buildCartItem(context, cartItem, cartProvider)),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
              // Total and Place Order button
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_formatPrice(cartProvider.totalPrice)} đ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FoodieButton(
                      text: FoodieStrings.placeOrder,
                      onPressed: cartProvider.canPlaceOrder
                          ? () {
                              // Place order logic
                              cartProvider.placeOrder();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(FoodieStrings.orderSuccess),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              cartItem.food.assetSrc,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.food.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatPrice(cartItem.food.price)} đ',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: primaryColor),
                onPressed: () {
                  cartProvider.updateQuantity(cartItem, cartItem.quantity - 1);
                },
              ),
              Text(
                '${cartItem.quantity}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: primaryColor),
                onPressed: () {
                  cartProvider.updateQuantity(cartItem, cartItem.quantity + 1);
                },
              ),
            ],
          ),
          // Remove button
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              cartProvider.removeItem(cartItem);
            },
          ),
        ],
      ),
    );
  }
}

