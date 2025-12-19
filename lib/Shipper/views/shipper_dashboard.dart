import 'package:flutter/material.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/Shipper/widgets/incoming_order_modal.dart';
import 'package:mobile/User/utils/utils.dart';

class ShipperDashboard extends StatefulWidget {
  static const routeName = '/shipper/dashboard';
  const ShipperDashboard({super.key});

  @override
  State<ShipperDashboard> createState() => _ShipperDashboardState();
}

class _ShipperDashboardState extends State<ShipperDashboard> {
  bool online = true;
  List<ShipperOrder> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });
    final fetched = await ShipperOrder.fetchAssignedOrders();
    setState(() {
      orders = fetched;
      isLoading = false;
    });
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

  void _showIncoming() {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No incoming orders')));
      return;
    }

    final o = orders.first;
    showDialog(
      context: context,
      builder: (_) => IncomingOrderModal(
        order: o,
        seconds: 30,
        onAccept: () {
          Navigator.pushNamed(context, '/shipper/order-detail', arguments: o);
        },
        onDecline: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order declined')));
        },
      ),
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
      ),
      body: SafeArea(
        child: Padding(
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
                    child: const Icon(Icons.person, color: whiteColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Người giao hàng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: SH-001',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        online ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: online ? primaryColor : Colors.grey,
                        ),
                      ),
                      Switch(
                        value: online,
                        activeColor: primaryColor,
                        onChanged: (v) {
                          setState(() => online = v);
                          if (v) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bắt đầu nhận đơn')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tạm nghỉ')),
                            );
                          }
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
                  _buildStatCard('Đơn hôm nay', isLoading ? '...' : '${orders.length}'),
                  _buildStatCard('Thu nhập', '1,250,000 VND'),
                  _buildStatCard('Thời gian', '4h 12m'),
                ],
              ),

              const SizedBox(height: 12),

              // Start / Pause button
              ElevatedButton(
                onPressed: () {
                  setState(() => online = !online);
                  if (online) _showIncoming();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(online ? 'Tạm nghỉ' : 'Bắt đầu nhận đơn'),
              ),

              const SizedBox(height: 12),

              const Text(
                'Đơn hàng gần nhất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Orders list
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (ctx, i) {
                          final o = orders[i];
                          final avatarLetter = (o.customerName.isNotEmpty ? o.customerName[0] : '?');
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: orangeLight,
                                child: Text(avatarLetter),
                              ),
                              title: Text('${o.id} • ${o.customerName}'),
                              subtitle: Text(
                                '${o.restaurantName ?? ''}\n${o.distanceKm.toStringAsFixed(1)} km • ${o.eta}',
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/shipper/order-detail',
                                      arguments: o,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                    ),
                                    child: const Text('Chi tiết'),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    o.status,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
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
}
