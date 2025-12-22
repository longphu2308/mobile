import 'package:flutter/material.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/core/models/user_model.dart';
import 'package:mobile/core/repositories/order_repository.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderRepository _orderRepository = OrderRepository();

  late OrderModel _order;
  ShipperProfileModel? _shipperProfile;
  UserProfileModel? _shipperUserProfile;
  bool _isLoading = true;
  bool _isLoadingShipper = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);

    try {
      // Fetch fresh order data with items
      final freshOrder = await _orderRepository.getOrderById(_order.id);
      if (freshOrder != null && mounted) {
        setState(() {
          _order = freshOrder;
        });

        // Load shipper info if available
        if (_order.shipperId != null) {
          _loadShipperInfo();
        }
      }
    } catch (e) {
      print('Error loading order details: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadShipperInfo() async {
    if (_order.shipperId == null) return;

    setState(() => _isLoadingShipper = true);

    try {
      final supabase = Supabase.instance.client;

      // Lấy shipper profile
      final shipperProfileData = await supabase
          .from('shipper_profiles')
          .select()
          .eq('user_id', _order.shipperId!)
          .maybeSingle();

      if (shipperProfileData != null) {
        _shipperProfile = ShipperProfileModel.fromMap(shipperProfileData);
      }

      // Lấy thông tin user profile của shipper
      final shipperUserProfileData = await supabase
          .from('user_profiles')
          .select()
          .eq('user_id', _order.shipperId!)
          .maybeSingle();

      if (shipperUserProfileData != null) {
        _shipperUserProfile = UserProfileModel.fromMap(shipperUserProfileData);
      }
    } catch (e) {
      print('Error loading shipper info: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingShipper = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          'Đơn hàng #${_order.id.substring(0, 8)}',
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: blackColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== ORDER ID & STATUS =====
                  _buildOrderInfoCard(),

                  const SizedBox(height: 20),

                  // ===== ITEMS SECTION =====
                  const Text(
                    'Thông tin sản phẩm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildItemsCard(),

                  const SizedBox(height: 20),

                  // ===== PRICE SUMMARY =====
                  _buildPriceSummaryCard(),

                  const SizedBox(height: 20),

                  // ===== NOTE SECTION =====
                  if (_order.note != null && _order.note!.isNotEmpty) ...[
                    const Text(
                      'Ghi chú từ khách hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.blue.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.note_alt,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _order.note ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ===== SHIPPER INFO =====
                  const Text(
                    'Thông tin Shipper',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildShipperInfoCard(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mã đơn hàng',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order.id.substring(0, 8).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(_order.status),
                    style: TextStyle(
                      color: _getStatusColor(_order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ngày đặt hàng',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateTime(_order.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._order.items.asMap().entries.map((entry) {
              int idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.foodName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Đơn giá: ₫${item.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'x${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₫${(item.price * item.quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (idx < _order.items.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng giá sản phẩm:'),
                Text(
                  '₫${_calculateSubtotal().toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phí giao hàng:'),
                Text(
                  '₫${_calculateDeliveryFee().toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (_calculateDiscount() > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giảm giá:'),
                  Text(
                    '-₫${_calculateDiscount().toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '₫${_order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipperInfoCard() {
    if (_order.shipperId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chưa có shipper',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Đang chờ shipper nhận đơn...',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingShipper) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: _shipperUserProfile?.avatarUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            _shipperUserProfile!.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.delivery_dining,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.delivery_dining,
                          color: Colors.blue,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _shipperUserProfile?.fullName ?? 'Shipper',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_shipperUserProfile?.phone != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _shipperUserProfile!.phone!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_shipperProfile != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Phương tiện
                  Column(
                    children: [
                      Icon(
                        _getVehicleIcon(_shipperProfile!.vehicleType),
                        color: primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _shipperProfile!.vehicleType?.displayName ?? 'Xe máy',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Biển số
                  if (_shipperProfile!.vehiclePlate != null)
                    Column(
                      children: [
                        const Icon(
                          Icons.confirmation_number,
                          color: primaryColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _shipperProfile!.vehiclePlate!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  // Rating
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 2),
                          Text(
                            _shipperProfile!.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_shipperProfile!.totalDeliveries} đơn',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType? vehicleType) {
    switch (vehicleType) {
      case VehicleType.bike:
        return Icons.pedal_bike;
      case VehicleType.car:
        return Icons.directions_car;
      default:
        return Icons.two_wheeler;
    }
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in _order.items) {
      subtotal += item.price * item.quantity;
    }
    return subtotal;
  }

  double _calculateDeliveryFee() {
    // Phí giao hàng = tổng tiền - tổng giá sản phẩm (nếu không có giảm giá)
    // Cần điều chỉnh logic này dựa trên cách tính phí trong hệ thống
    return 0;
  }

  double _calculateDiscount() {
    double subtotal = _calculateSubtotal();
    double deliveryFee = _calculateDeliveryFee();
    double discount = subtotal + deliveryFee - _order.totalAmount;
    return discount > 0 ? discount : 0;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.indigo;
      case OrderStatus.readyForPickup:
        return Colors.teal;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    return status.displayName;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
