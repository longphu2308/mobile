import 'package:flutter/material.dart';
import 'package:mobile/User/state/foodie_store.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/views/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _vendorId;
  String? _vendorName;
  DeliveryMethod _deliveryMethod = DeliveryMethod.door;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _vendorId = args['vendorId'] as String?;
      _vendorName = args['vendorName'] as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<FoodieStore>(
        builder: (context, store, _) {
          final vendorId = _vendorId;
          if (vendorId == null) {
            return const Center(
              child: Text('Không tìm thấy đơn hàng.'),
            );
          }
          final vendor = store.cartForVendor(vendorId);
          if (vendor == null) {
            return const Center(
              child: Text('Giỏ hàng không hợp lệ'),
            );
          }

          final total = formatCurrency(vendor.total);
          final user = store.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Address details',
                  actionText: 'change',
                  onActionTap: () => _openAddressSheet(store),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.address,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Delivery method.'),
                const SizedBox(height: 12),
                _InfoCard(
                  child: SegmentedButton<DeliveryMethod>(
                    segments: const [
                      ButtonSegment(
                        value: DeliveryMethod.door,
                        label: Text('Door delivery'),
                        icon: Icon(Icons.delivery_dining_outlined),
                      ),
                      ButtonSegment(
                        value: DeliveryMethod.pickup,
                        label: Text('Pick up'),
                        icon: Icon(Icons.store_mall_directory_outlined),
                      ),
                    ],
                    selected: {_deliveryMethod},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _deliveryMethod = selection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.white,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? primaryColor
                            : Colors.grey[700],
                      ),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Payment method'),
                const SizedBox(height: 12),
                _InfoCard(
                  child: SegmentedButton<PaymentMethod>(
                    segments: const [
                      ButtonSegment(
                        value: PaymentMethod.cash,
                        label: Text('Cash'),
                        icon: Icon(Icons.attach_money),
                      ),
                      ButtonSegment(
                        value: PaymentMethod.bank,
                        label: Text('Bank account'),
                        icon: Icon(Icons.account_balance),
                      ),
                    ],
                    selected: {_paymentMethod},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _paymentMethod = selection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.white,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? primaryColor
                            : Colors.grey[700],
                      ),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Items'),
                const SizedBox(height: 12),
                _InfoCard(
                  child: Column(
                    children: [
                      ...vendor.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity} x ${item.food.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${formatCurrency(item.subtotal)} đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$total đ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FoodieButton(
                  text: 'Proceed to payment',
                  onPressed: () {
                    final order = store.placeOrderForVendor(
                      vendorId,
                      deliveryMethod: _deliveryMethod,
                      paymentMethod: _paymentMethod,
                    );
                    if (order != null && mounted) {
                      final vendorLabel = _vendorName ?? vendor.vendorName;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đặt hàng thành công tại $vendorLabel!',
                          ),
                        ),
                      );
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(dashboardRoute),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openAddressSheet(FoodieStore store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddressSheet(
            user: store.user,
            onSave: (user) {
              store.updateProfile(user);
              Navigator.pop(context);
              setState(() {});
            },
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onActionTap,
  });

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
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionText!,
              style: const TextStyle(color: primaryColor),
            ),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 24,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AddressSheet extends StatefulWidget {
  final FoodieUser user;
  final ValueChanged<FoodieUser> onSave;

  const _AddressSheet({
    required this.user,
    required this.onSave,
  });

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cập nhật địa chỉ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Bắt buộc' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Bắt buộc' : null,
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
              maxLines: 2,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 16),
            FoodieButton(
              text: 'Lưu',
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSave(
                    widget.user.copyWith(
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      address: _addressController.text.trim(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}



