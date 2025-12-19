import 'package:flutter/material.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
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
  String shipperName = 'Người giao hàng';
  String shipperRefId = '';
  String vehicleInfo = '';

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
    // load shipper profile info
    try {
      final supabase = SupabaseService();
      final uid = supabase.userId;
      if (uid != null) {
        final up = await supabase.from('user_profiles').select().eq('user_id', uid).maybeSingle();
        final sp = await supabase.from('shipper_profiles').select().eq('user_id', uid).maybeSingle();
        setState(() {
          shipperName = up != null ? (up['full_name'] ?? shipperName) : shipperName;
          shipperRefId = uid.substring(0, 8);
          if (sp != null) {
            final vt = sp['vehicle_type'] ?? '';
            final plate = sp['vehicle_plate'] ?? '';
            vehicleInfo = (vt != '' || plate != '') ? '$vt • Plate: $plate' : '';
          }
        });
      }
    } catch (_) {}
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
                    child: Text(shipperName.isNotEmpty ? shipperName[0] : '?', style: const TextStyle(color: whiteColor)),
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
                          'ID: ${shipperRefId}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (vehicleInfo.isNotEmpty) Text(vehicleInfo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom +
                            kBottomNavigationBarHeight +
                            24,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (ctx, i) {
                        final o = orders[i];
                        final avatarLetter =
                            (o.customerName.isNotEmpty ? o.customerName[0] : '?');

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: orangeLight,
                              child: Text(
                                avatarLetter,
                                style: const TextStyle(color: whiteColor),
                              ),
                            ),

                            /// TITLE
                            title: Text(
                              '${o.id} • ${o.customerName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            /// SUBTITLE (đã đưa status xuống đây)
                            subtitle: Text(
                              '${o.restaurantName ?? ''}\n'
                              '${o.distanceKm.toStringAsFixed(1)} km • ${o.eta}\n'
                              '${o.status}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            isThreeLine: true,
                            trailing: SizedBox(
                              width: 90,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/shipper/order-detail',
                                      arguments: o,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(70, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Chi tiết',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    o.status,
                                    style: const TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
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
