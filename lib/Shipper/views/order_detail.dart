import 'package:flutter/material.dart';
import 'package:mobile/Shipper/models/shipper_order.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/Shipper/widgets/shipper_bottom_nav.dart';
import 'package:mobile/core/services/location_service.dart';
import 'package:mobile/Shipper/widgets/delivery_map_widget.dart';
import 'package:latlong2/latlong.dart';

double _statusProgress(String status) {
  // Map ordered lifecycle to progress values (0.0 -> 1.0)
  switch (status.toLowerCase()) {
    case 'pending':
      return 0.0;
    case 'confirmed':
      return 0.2;
    case 'preparing':
      return 0.4;
    case 'ready_for_pickup':
      return 0.6;
    case 'delivering':
      return 0.8;
    case 'delivered':
      return 1.0;
    case 'cancelled':
      return 0.0;
    default:
      return 0.0;
  }
}

class OrderDetail extends StatefulWidget {
  static const routeName = '/shipper/order-detail';
  const OrderDetail({super.key});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  late ShipperOrder order;
  List<OrderItem> items = [];
  bool isLoadingItems = false;
  bool _isUpdatingStatus = false;
  LatLng? _shipperLocation;
  LatLng? _restaurantLocation;
  LatLng? _customerLocation;
  RouteDestination? _activeRoute;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! ShipperOrder) {
      // Defensive: if called without a proper ShipperOrder, go back.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order data missing')));
        Navigator.maybePop(context);
      });
      return;
    }
    order = args;
    items = List.from(order.items);

    // Fetch missing data (restaurant info, customer info, items)
    _loadFullOrderData();
  }

  /// Load all order data including restaurant and customer info
  Future<void> _loadFullOrderData() async {
    // Load items if empty
    if (items.isEmpty) {
      _fetchItems();
    }

    // Fetch restaurant and customer info if missing
    await _fetchOrderDetails();

    // Load locations for map
    _loadLocations();
  }

  /// Fetch restaurant and customer info for the order
  Future<void> _fetchOrderDetails() async {
    try {
      final supabase = SupabaseService();

      // Fetch order with restaurant info
      final orderData = await supabase
          .from('orders')
          .select('*, restaurants(*)')
          .eq('order_id', order.id)
          .maybeSingle();

      if (!mounted) return;

      if (orderData != null) {
        String? restaurantName = order.restaurantName;
        String? restaurantAddress = order.restaurantAddress;
        String? restaurantPhone = order.restaurantPhone;
        String? restaurantId = order.restaurantId;
        String customerName = order.customerName;
        String? customerPhone = order.customerPhone;

        // Get restaurant info
        final restaurant = orderData['restaurants'];
        if (restaurant != null) {
          restaurantName = restaurant['name'] ?? restaurantName;
          restaurantAddress = restaurant['address'] ?? restaurantAddress;
          restaurantPhone = restaurant['phone'] ?? restaurantPhone;
          restaurantId = orderData['restaurant_id'] ?? restaurantId;
        }

        // Fetch customer info from user_profiles separately
        final userId = orderData['user_id'];
        if (userId != null) {
          final userProfile = await supabase
              .from('user_profiles')
              .select('full_name, phone')
              .eq('user_id', userId)
              .maybeSingle();

          if (!mounted) return;

          if (userProfile != null) {
            customerName = userProfile['full_name'] ?? customerName;
            customerPhone = userProfile['phone'] ?? customerPhone;
            print(
              '📱 Customer info loaded: name=$customerName, phone=$customerPhone',
            );
          } else {
            print('⚠️ No user_profile found for user_id: $userId');
          }
        }

        setState(() {
          order = ShipperOrder(
            id: order.id,
            customerName: customerName.isNotEmpty
                ? customerName
                : order.customerName,
            address: orderData['delivery_address'] ?? order.address,
            distanceKm: order.distanceKm,
            status: orderData['status'] ?? order.status,
            total:
                (orderData['total_amount'] as num?)?.toDouble() ?? order.total,
            items: order.items,
            eta: order.eta,
            restaurantName: restaurantName,
            restaurantAddress: restaurantAddress,
            fee: order.fee,
            customerPhone: customerPhone,
            restaurantPhone: restaurantPhone,
            restaurantId: restaurantId,
          );
        });

        print(
          '✅ Order details loaded: restaurant=${order.restaurantName}, customer=${order.customerName}, phone=${order.customerPhone}',
        );
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  Future<void> _loadLocations() async {
    // Get shipper current location
    final position = await LocationService().getCurrentLocation();
    if (!mounted) return;

    if (position != null) {
      setState(() {
        _shipperLocation = LatLng(position.latitude, position.longitude);
      });
      print('✅ Shipper location: $_shipperLocation');
    } else {
      print('❌ Cannot get shipper GPS location');
    }

    // Get restaurant and customer locations
    try {
      final supabase = SupabaseService();
      // Fetch restaurant location
      if (order.restaurantId != null) {
        final restaurant = await supabase
            .from('restaurants')
            .select('latitude, longitude')
            .eq('restaurant_id', order.restaurantId!)
            .maybeSingle();
        if (!mounted) return;
        if (restaurant != null) {
          final lat = (restaurant['latitude'] as num?)?.toDouble();
          final lon = (restaurant['longitude'] as num?)?.toDouble();
          if (lat != null && lon != null) {
            setState(() {
              _restaurantLocation = LatLng(lat, lon);
            });
          }
        }
      }

      // Get customer location from order
      final orderData = await supabase
          .from('orders')
          .select('delivery_latitude, delivery_longitude')
          .eq('order_id', order.id)
          .maybeSingle();
      if (!mounted) return;
      if (orderData != null) {
        final lat = (orderData['delivery_latitude'] as num?)?.toDouble();
        final lon = (orderData['delivery_longitude'] as num?)?.toDouble();
        print('🗺️ Customer location from DB: lat=$lat, lon=$lon');
        if (lat != null && lon != null) {
          setState(() {
            _customerLocation = LatLng(lat, lon);
          });
          print('✅ Customer location set: $_customerLocation');
        } else {
          print('❌ Customer location is NULL in database');
        }
      }
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  Future<void> _fetchItems() async {
    setState(() => isLoadingItems = true);
    try {
      final supabase = SupabaseService();
      // DEBUG: log before querying
      print('OrderDetail._fetchItems: fetching items for orderId=${order.id}');
      dynamic itemsData = await supabase
          .from('order_items')
          .select()
          .eq('order_id', order.id);
      print(
        'OrderDetail._fetchItems: raw itemsData length=${(itemsData as List?)?.length ?? 0}',
      );
      if (itemsData == null || (itemsData as List).isEmpty) {
        try {
          final orderWithItems = await supabase
              .from('orders')
              .select('order_items(*)')
              .eq('order_id', order.id)
              .maybeSingle();
          final embedded =
              (orderWithItems != null && orderWithItems['order_items'] != null)
              ? (orderWithItems['order_items'] as List<dynamic>)
              : <dynamic>[];
          if (embedded.isNotEmpty) {
            itemsData = embedded;
            print(
              'OrderDetail._fetchItems: fetched items via orders relation, count=${embedded.length}',
            );
          }
        } catch (e) {
          // ignore
        }
      }
      final fetched = (itemsData as List? ?? []).map((i) {
        final price = (i['price'] as num?)?.toDouble() ?? 0.0;
        return OrderItem(
          name: i['food_name'] ?? '',
          qty: (i['quantity'] as int?) ?? (i['quantity'] as num?)?.toInt() ?? 0,
          price: price,
        );
      }).toList();
      setState(() {
        items = fetched;
      });
      print('ORDER.ID = ${order.id}');
      print('TYPE = ${order.id.runtimeType}');
    } catch (e) {
      // ignore errors for now
    } finally {
      setState(() => isLoadingItems = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.id}'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map at the top
                      SizedBox(
                        height: 280,
                        child: DeliveryMapWidget(
                          shipperLocation: _shipperLocation,
                          restaurantLocation: _restaurantLocation,
                          customerLocation: _customerLocation,
                          activeRoute: _activeRoute,
                          onRouteChanged: (route) {
                            setState(() => _activeRoute = route);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Route selection buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _activeRoute =
                                      _activeRoute ==
                                          RouteDestination.restaurant
                                      ? null
                                      : RouteDestination.restaurant;
                                });
                              },
                              icon: Icon(
                                Icons.restaurant,
                                color:
                                    _activeRoute == RouteDestination.restaurant
                                    ? primaryColor
                                    : null,
                              ),
                              label: Text(
                                'Đến nhà hàng',
                                style: TextStyle(
                                  color:
                                      _activeRoute ==
                                          RouteDestination.restaurant
                                      ? primaryColor
                                      : null,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      _activeRoute ==
                                          RouteDestination.restaurant
                                      ? primaryColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                print('🔘 Button "Đến khách" pressed');
                                print('   Shipper: $_shipperLocation');
                                print('   Customer: $_customerLocation');
                                setState(() {
                                  _activeRoute =
                                      _activeRoute == RouteDestination.customer
                                      ? null
                                      : RouteDestination.customer;
                                  print(
                                    '   Active route set to: $_activeRoute',
                                  );
                                });
                              },
                              icon: Icon(
                                Icons.location_on,
                                color: _activeRoute == RouteDestination.customer
                                    ? primaryColor
                                    : null,
                              ),
                              label: Text(
                                'Đến khách',
                                style: TextStyle(
                                  color:
                                      _activeRoute == RouteDestination.customer
                                      ? primaryColor
                                      : null,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      _activeRoute == RouteDestination.customer
                                      ? primaryColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Restaurant info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nhà hàng: ${order.restaurantName ?? '-'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if ((order.restaurantAddress ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Text(
                                    'Địa chỉ: ${order.restaurantAddress}',
                                  ),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.phone, size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            order.restaurantPhone ??
                                                '-'.toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Mở dẫn đường (mock)'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.map),
                                    label: const Text('Đường đi'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Customer info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khách hàng: ${order.customerName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Địa chỉ: ${order.address}'),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.phone, size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            order.customerPhone ?? '-',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Mở dẫn đường đến khách (mock)',
                                            ),
                                          ),
                                        ),
                                    icon: const Icon(Icons.navigation),
                                    label: const Text('Đường đi'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Notes
                      if (items.isEmpty && !isLoadingItems)
                        const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text('Ghi chú: ${order.status}'),
                      ),

                      const SizedBox(height: 8),

                      // Items
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chi tiết đơn',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (isLoadingItems)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              if (!isLoadingItems && items.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Không có món hàng.'),
                                ),
                              // Items list
                              ...items.map(
                                (i) => Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.grey.shade200,
                                        child: Text(
                                          '${i.qty}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        i.name,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        '${i.price.toInt()} VND / cái',
                                      ),
                                      trailing: Text(
                                        '${i.total.toInt()} VND',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${order.total.toInt()} VND',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Status progress
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trạng thái đơn',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _statusProgress(order.status),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Pickup'),
                                  Text('Đang giao'),
                                  Text('Đã giao'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Single action button for allowed status transitions
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Builder(
                  builder: (ctx) {
                    final status = order.status.toLowerCase();
                    String? nextStatus;
                    String buttonLabel = 'No action';
                    switch (status) {
                      case 'pending':
                        nextStatus = 'confirmed';
                        buttonLabel = 'Confirm Order';
                        break;
                      case 'ready_for_pickup':
                        nextStatus = 'delivering';
                        buttonLabel = 'Start Delivery';
                        break;
                      case 'delivering':
                        nextStatus = 'delivered';
                        buttonLabel = 'Mark Delivered';
                        break;
                      default:
                        nextStatus = null;
                        buttonLabel = 'No action';
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            onPressed: (nextStatus == null || _isUpdatingStatus)
                                ? null
                                : () => _changeStatus(nextStatus!, ctx),
                            child: _isUpdatingStatus
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(buttonLabel),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: shipperBottomNav(context, 0),
    );
  }

  Future<void> _changeStatus(String nextStatus, BuildContext ctx) async {
    setState(() => _isUpdatingStatus = true);
    try {
      final supabase = SupabaseService();
      await supabase
          .from('orders')
          .update({'status': nextStatus})
          .eq('order_id', order.id);
      // Update local order instance by recreating with new status
      setState(() {
        order = ShipperOrder(
          id: order.id,
          customerName: order.customerName,
          address: order.address,
          distanceKm: order.distanceKm,
          status: nextStatus,
          total: order.total,
          items: order.items,
          eta: order.eta,
          restaurantName: order.restaurantName,
          restaurantAddress: order.restaurantAddress,
          fee: order.fee,
          customerPhone: order.customerPhone,
          restaurantPhone: order.restaurantPhone,
        );
      });
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(SnackBar(content: Text('Status updated to $nextStatus')));
    } catch (e) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    } finally {
      setState(() => _isUpdatingStatus = false);
    }
  }
}
