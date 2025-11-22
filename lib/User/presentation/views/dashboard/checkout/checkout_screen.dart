import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/formatters.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/order_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/models/cart_model.dart';
import 'package:mobile/config/routes.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  String _selectedPaymentMethod = 'cash';
  final List<String> _paymentMethods = ['cash', 'card', 'momo', 'zalopay'];

  Map<String, List<CartItemModel>> _groupItemsByRestaurant(
    List<CartItemModel> items,
  ) {
    final Map<String, List<CartItemModel>> grouped = {};
    for (var item in items) {
      final restaurantName = item.foodName;
      if (!grouped.containsKey(restaurantName)) {
        grouped[restaurantName] = [];
      }
      grouped[restaurantName]!.add(item);
    }
    return grouped;
  }

  @override
  void initState() {
    super.initState();
    // Load user address if available
    final authController = Provider.of<AuthController>(context, listen: false);
    if (authController.currentUser?.address != null) {
      _addressController.text = authController.currentUser!.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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
      body: Consumer2<CartController, AuthController>(
        builder: (context, cartController, authController, child) {
          if (cartController.items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          final groupedItems = _groupItemsByRestaurant(cartController.items);
          final restaurantNames = groupedItems.keys.toList();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery Address Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
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
                            Row(
                              children: [
                                Icon(Icons.location_on, color: primaryColor),
                                const SizedBox(width: 8),
                                const Text(
                                  'Địa chỉ giao hàng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                hintText: 'Nhập địa chỉ giao hàng',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                                filled: true,
                                fillColor: bgColor,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),

                      // Payment Method Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
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
                            Row(
                              children: [
                                Icon(Icons.payment, color: primaryColor),
                                const SizedBox(width: 8),
                                const Text(
                                  'Phương thức thanh toán',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._paymentMethods.map((method) => RadioListTile<String>(
                                  title: Text(_getPaymentMethodName(method)),
                                  value: method,
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethod = value!;
                                    });
                                  },
                                  activeColor: primaryColor,
                                )),
                          ],
                        ),
                      ),

                      // Order Items Section
                      const Text(
                        'Chi tiết đơn hàng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...restaurantNames.map((restaurantName) {
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
                                      child: Image.network(
                                        item.imageUrl,
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
                                            item.foodName,
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
                                            'Số lượng: ${item.quantity}',
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
                      }),
                    ],
                  ),
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
                            'Tổng tiền:',
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
                            if (_addressController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng nhập địa chỉ giao hàng'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
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
                            'Hoàn tất đặt hàng',
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

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Tiền mặt';
      case 'card':
        return 'Thẻ tín dụng/Ghi nợ';
      case 'momo':
        return 'Ví MoMo';
      case 'zalopay':
        return 'Ví ZaloPay';
      default:
        return method;
    }
  }

  void _completeOrder(BuildContext context, CartController cartController) {
    final orderController = Provider.of<OrderController>(
      context,
      listen: false,
    );
    final totalPrice = cartController.totalPrice;
    final items = List<CartItemModel>.from(cartController.items);
    final restaurantId = cartController.currentRestaurantId ?? '';
    final deliveryAddress = _addressController.text.trim();
    final paymentMethod = _selectedPaymentMethod;

    print(
      'Starting order creation with ${items.length} items, total: $totalPrice',
    );

    // Create order and handle the result
    orderController
        .createOrder(
          items,
          totalPrice,
          restaurantId: restaurantId,
          deliveryAddress: deliveryAddress,
          paymentMethod: paymentMethod,
        )
        .then((success) {
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

            // Navigate back to dashboard with History tab selected
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                userDashboardRoute,
                (route) => false, // Remove all previous routes
                arguments: {'initialIndex': 3}, // Tab index 3 = History
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
                    orderController.errorMessage ??
                        'Lỗi đặt hàng. Vui lòng thử lại.',
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
