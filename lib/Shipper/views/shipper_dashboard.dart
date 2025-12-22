import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/Shipper/controllers/shipper_controller.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/User/utils/utils.dart';

class ShipperDashboard extends StatefulWidget {
  static const routeName = '/shipper/dashboard';
  const ShipperDashboard({super.key});

  @override
  State<ShipperDashboard> createState() => _ShipperDashboardState();
}

class _ShipperDashboardState extends State<ShipperDashboard> {
  late ShipperController _shipperController;
  String shipperName = 'Người giao hàng';
  String shipperRefId = '';
  String vehicleInfo = '';
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _shipperController = Get.find<ShipperController>();
    _loadShipperProfile();

    // Auto start listening if online
    if (!_shipperController.isOnline) {
      _shipperController.toggleOnlineStatus();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadShipperProfile() async {
    try {
      final supabase = SupabaseService();
      final uid = supabase.userId;
      if (uid != null) {
        final up = await supabase
            .from('user_profiles')
            .select()
            .eq('user_id', uid)
            .maybeSingle();
        final sp = await supabase
            .from('shipper_profiles')
            .select()
            .eq('user_id', uid)
            .maybeSingle();
        if (_mounted) {
          setState(() {
            shipperName = up != null
                ? (up['full_name'] ?? shipperName)
                : shipperName;
            shipperRefId = uid.substring(0, 8);
            if (sp != null) {
              final vt = sp['vehicle_type'] ?? '';
              final plate = sp['vehicle_plate'] ?? '';
              vehicleInfo = (vt != '' || plate != '')
                  ? '$vt • Plate: $plate'
                  : '';
            }
          });
        }
      }
    } catch (_) {}
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipper Dashboard'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _shipperController.refresh(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final isOnline = _shipperController.isOnline;
          final availableOrders = _shipperController.availableOrders;
          final assignedOrders = _shipperController.assignedOrders;
          final isLoading = _shipperController.isLoading;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar: avatar + status
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: orangeLight,
                      child: Text(
                        shipperName.isNotEmpty ? shipperName[0] : '?',
                        style: const TextStyle(color: whiteColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shipperName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: $shipperRefId',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (vehicleInfo.isNotEmpty)
                            Text(
                              vehicleInfo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: isOnline ? primaryColor : Colors.grey,
                          ),
                        ),
                        Switch(
                          value: isOnline,
                          activeColor: primaryColor,
                          onChanged: (v) {
                            _shipperController.toggleOnlineStatus();
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Quick info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      'Đơn hôm nay',
                      '${_shipperController.todayOrderCount}',
                    ),
                    _buildStatCard(
                      'Thu nhập',
                      '${_formatAmount(_shipperController.todayEarnings)} VND',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Available orders section (pending orders to accept)
                if (isOnline && availableOrders.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đơn hàng mới (${availableOrders.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: availableOrders.length,
                            itemBuilder: (ctx, i) {
                              final order = availableOrders[i];
                              return _buildAvailableOrderCard(order);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Assigned orders section
                Text(
                  'Đơn hàng đang xử lý (${assignedOrders.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Orders list
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : assignedOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isOnline
                                    ? Icons.hourglass_empty
                                    : Icons.wifi_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isOnline
                                    ? 'Chưa có đơn hàng nào'
                                    : 'Bật Online để nhận đơn',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).padding.bottom +
                                kBottomNavigationBarHeight +
                                24,
                          ),
                          itemCount: assignedOrders.length,
                          itemBuilder: (ctx, i) {
                            final order = assignedOrders[i];
                            return _buildAssignedOrderCard(order);
                          },
                        ),
                ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: primaryColor,
        onTap: (idx) {
          if (idx == 1) Navigator.pushNamed(context, '/shipper/history');
          if (idx == 2) Navigator.pushNamed(context, '/shipper/profile');
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.map),
        onPressed: () => Navigator.pushNamed(context, '/shipper/tracking'),
      ),
    );
  }

  Widget _buildAvailableOrderCard(OrderModel order) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatAmount(order.totalAmount)} VND',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              order.deliveryAddress,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await _shipperController.acceptOrder(
                      order.id,
                    );
                    if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _shipperController.error ?? 'Không thể nhận đơn',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Nhận đơn', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _shipperController.declineOrder(order.id),
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: Icon(
            _getStatusIcon(order.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          'Đơn #${order.id.substring(0, 8)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.deliveryAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status.displayName,
                style: TextStyle(
                  fontSize: 11,
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_formatAmount(order.totalAmount)}đ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/shipper/order-detail',
                  arguments: order,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.zero,
                minimumSize: const Size(70, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Chi tiết', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.readyForPickup:
        return Colors.teal;
      case OrderStatus.delivering:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.readyForPickup:
        return Icons.takeout_dining;
      case OrderStatus.delivering:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}
