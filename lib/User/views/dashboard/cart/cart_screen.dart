import 'package:flutter/material.dart';
import 'package:mobile/User/state/foodie_store.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/views/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: Consumer<FoodieStore>(
        builder: (context, store, _) {
          final vendorCarts = store.vendorCarts;
          if (vendorCarts.isEmpty) {
            return const _EmptyCart();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(horizontalPadding),
            itemCount: vendorCarts.length,
            itemBuilder: (context, index) {
              final cart = vendorCarts[index];
              return _VendorCartSection(cart: cart);
            },
          );
        },
      ),
    );
  }
}

class _VendorCartSection extends StatelessWidget {
  final VendorCart cart;

  const _VendorCartSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    final store = context.read<FoodieStore>();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            blurRadius: 20,
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cart.vendorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => store.clearVendorCart(cart.vendorId),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      item.food.assetSrc,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.food.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatCurrency(item.food.price)} đ',
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            store.decreaseQuantity(item.food),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            store.increaseQuantity(item.food),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => store.removeFromCart(item.food),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${formatCurrency(cart.total)} đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FoodieButton(
            text: 'Tiếp tục thanh toán',
            onPressed: () {
              Navigator.pushNamed(
                context,
                checkoutRoute,
                arguments: {
                  'vendorId': cart.vendorId,
                  'vendorName': cart.vendorName,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 96,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng đang trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Thêm món ăn để bắt đầu đặt hàng nhé!'),
        ],
      ),
    );
  }
}

