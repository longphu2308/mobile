import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/formatters.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/order_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/models/cart_model.dart';
import 'package:mobile/config/routes.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'cash';
  String _selectedDeliveryMethod = 'door';
  double _deliveryFee = 10000;

  final List<_DeliveryOption> _deliveryOptions = const [
    _DeliveryOption(
      title: 'Economy delivery',
      subtitle: 'GIAO HANG TIET KIEM',
      fee: 10000,
    ),
    _DeliveryOption(
      title: 'Express delivery',
      subtitle: 'SHIP HOA TOC',
      fee: 20000,
    ),
  ];

  final List<_PaymentOption> _paymentOptions = const [
    _PaymentOption(
      key: 'cash',
      label: 'Cash',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFFFFB347),
    ),
    _PaymentOption(
      key: 'card',
      label: 'Card',
      icon: Icons.credit_card,
      color: Color(0xFF6C63FF),
    ),
    _PaymentOption(
      key: 'bank',
      label: 'Bank account',
      icon: Icons.account_balance,
      color: Color(0xFFFF5E95),
    ),
  ];

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
        title: const Text('Checkout', style: TextStyle(color: blackColor)),
        centerTitle: true,
      ),
      body: GetBuilder<CartController>(
        builder: (cartController) {
          final authController = Get.find<AuthController>();
          final orderController = Get.find<OrderController>();
          if (cartController.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          final groupedItems = _groupItemsByRestaurant(cartController.items);
          final restaurantNames = groupedItems.keys.toList();
          final double totalWithDelivery =
              cartController.totalPrice +
              (_selectedDeliveryMethod == 'door' ? _deliveryFee : 0);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AddressCard(
                        name: authController.fullName ?? 'No name',
                        address: authController.address ?? 'No address saved',
                        phone: authController.phone ?? 'No phone number',
                        onChange: () =>
                            Navigator.pushNamed(context, userEditProfileRoute),
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle(
                        'Delivery method',
                        actionLabel: _selectedDeliveryMethod == 'door'
                            ? 'change'
                            : null,
                        onAction: _selectedDeliveryMethod == 'door'
                            ? _showDeliveryOptionsDialog
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _DeliverySelector(
                        selectedMethod: _selectedDeliveryMethod,
                        deliveryFee: _selectedDeliveryMethod == 'door'
                            ? _deliveryFee
                            : 0,
                        onChanged: (value) async {
                          setState(() => _selectedDeliveryMethod = value);
                          if (value == 'door') {
                            await _showDeliveryOptionsDialog();
                          } else {
                            setState(() {
                              _deliveryFee = 0;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Payment method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._paymentOptions.map(
                        (option) => _PaymentTile(
                          option: option,
                          isSelected: option.key == _selectedPaymentMethod,
                          onTap: () => setState(
                            () => _selectedPaymentMethod = option.key,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Order summary',
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
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, _, __) =>
                                            Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: Colors.grey[600],
                                              ),
                                            ),
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
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'x${item.quantity}',
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
                          ],
                        );
                      }),
                      const SizedBox(height: 80),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryRow(
                        label: 'Subtotal',
                        value: formatPrice(cartController.totalPrice),
                      ),
                      const SizedBox(height: 4),
                      _SummaryRow(
                        label: 'Delivery fee',
                        value: _selectedDeliveryMethod == 'door'
                            ? formatPrice(_deliveryFee)
                            : '0',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: blackColor,
                            ),
                          ),
                          Text(
                            formatPrice(totalWithDelivery),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: blackColor,
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
                            final address = authController.address;
                            if (address == null || address.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please update your address before placing order',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            _completeOrder(
                              context,
                              cartController,
                              orderController,
                              totalWithDelivery,
                              address,
                            );
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
                            'Proceed to payment',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  Future<void> _showDeliveryOptionsDialog() async {
    final selected = await showDialog<_DeliveryOption>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Please note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _deliveryOptions
              .map(
                (option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.subtitle.toUpperCase()),
                  subtitle: Text(formatPrice(option.fee)),
                  onTap: () => Navigator.pop(context, option),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() {
        _deliveryFee = selected.fee;
      });
    }
  }

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

  void _completeOrder(
    BuildContext context,
    CartController cartController,
    OrderController orderController,
    double totalPrice,
    String deliveryAddress,
  ) {
    final items = List<CartItemModel>.from(cartController.items);
    final restaurantId = cartController.currentRestaurantId ?? '';
    final paymentMethod = _selectedPaymentMethod;

    orderController
        .createOrder(
          items,
          totalPrice,
          restaurantId: restaurantId,
          deliveryAddress: deliveryAddress,
          paymentMethod: paymentMethod,
        )
        .then((success) {
          if (!context.mounted) return;
          if (success) {
            cartController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order placed successfully!'),
                duration: Duration(seconds: 2),
                backgroundColor: Color(0xFFFF6B35),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              userDashboardRoute,
              (route) => false,
              arguments: {'initialIndex': 3},
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  orderController.errorMessage ??
                      'Order failed. Please try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }
}

class _AddressCard extends StatelessWidget {
  final String name;
  final String address;
  final String phone;
  final VoidCallback onChange;

  const _AddressCard({
    required this.name,
    required this.address,
    required this.phone,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Address details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: blackColor,
                ),
              ),
              TextButton(onPressed: onChange, child: const Text('change')),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(address, style: const TextStyle(color: greyColor)),
          const SizedBox(height: 4),
          Text(phone, style: const TextStyle(color: greyColor)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitle(this.title, {this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: blackColor,
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _DeliverySelector extends StatelessWidget {
  final String selectedMethod;
  final double deliveryFee;
  final ValueChanged<String> onChanged;

  const _DeliverySelector({
    required this.selectedMethod,
    required this.deliveryFee,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DeliveryTile(
          title: 'Door delivery',
          subtitle: formatPrice(deliveryFee),
          isSelected: selectedMethod == 'door',
          onTap: () => onChanged('door'),
        ),
        const SizedBox(height: 12),
        _DeliveryTile(
          title: 'Pick up',
          subtitle: 'Collect at store',
          isSelected: selectedMethod == 'pickup',
          onTap: () => onChanged('pickup'),
        ),
      ],
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
              color: isSelected ? primaryColor : greyColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: greyColor),
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

class _PaymentTile extends StatelessWidget {
  final _PaymentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: option.color.withOpacity(0.2),
              child: Icon(option.icon, color: option.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
              color: isSelected ? primaryColor : greyColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: greyColor, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: blackColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DeliveryOption {
  final String title;
  final String subtitle;
  final double fee;

  const _DeliveryOption({
    required this.title,
    required this.subtitle,
    required this.fee,
  });
}

class _PaymentOption {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _PaymentOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}
