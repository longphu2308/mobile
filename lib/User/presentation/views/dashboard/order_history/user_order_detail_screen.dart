import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/models/order_model.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:mobile/core/services/location_service.dart';
import 'package:mobile/core/services/routing_service.dart';
import 'package:mobile/User/utils/utils.dart';
import 'dart:async';

class UserOrderDetailScreen extends StatefulWidget {
  static const routeName = '/user/order-detail';
  final OrderModel order;

  const UserOrderDetailScreen({super.key, required this.order});

  @override
  State<UserOrderDetailScreen> createState() => _UserOrderDetailScreenState();
}

class _UserOrderDetailScreenState extends State<UserOrderDetailScreen> {
  bool _isLoading = true;

  // Location data
  LatLng? _shipperLocation;
  LatLng? _restaurantLocation;
  LatLng? _customerLocation;
  List<LatLng>? _routePoints;

  // Restaurant & Shipper info
  String? _restaurantName;
  String? _restaurantAddress;
  String? _restaurantPhone;
  String? _shipperName;
  String? _shipperPhone;

  // Map controller
  final MapController _mapController = MapController();
  Timer? _shipperLocationTimer;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  @override
  void dispose() {
    _shipperLocationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);

    try {
      final supabase = SupabaseService();

      // Fetch order with restaurant info
      final orderData = await supabase
          .from('orders')
          .select('*, restaurants(*)')
          .eq('order_id', widget.order.id)
          .maybeSingle();

      if (orderData != null) {
        // Get restaurant info
        final restaurant = orderData['restaurants'];
        if (restaurant != null) {
          _restaurantName = restaurant['name'];
          _restaurantAddress = restaurant['address'];
          _restaurantPhone = restaurant['phone'];

          final lat = (restaurant['latitude'] as num?)?.toDouble();
          final lon = (restaurant['longitude'] as num?)?.toDouble();
          if (lat != null && lon != null) {
            _restaurantLocation = LatLng(lat, lon);
          }
        }

        // Get customer location from order
        final lat = (orderData['delivery_latitude'] as num?)?.toDouble();
        final lon = (orderData['delivery_longitude'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          _customerLocation = LatLng(lat, lon);
        }

        // Get shipper info if assigned
        if (widget.order.shipperId != null) {
          await _loadShipperInfo(widget.order.shipperId!);
          _startShipperLocationUpdates();
        }
      }

      // Load route if we have locations
      await _loadRoute();
    } catch (e) {
      print('Error loading order details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadShipperInfo(String shipperId) async {
    try {
      final supabase = SupabaseService();

      // Get shipper profile
      final shipperProfile = await supabase
          .from('user_profiles')
          .select('full_name, phone')
          .eq('user_id', shipperId)
          .maybeSingle();

      if (shipperProfile != null) {
        _shipperName = shipperProfile['full_name'];
        _shipperPhone = shipperProfile['phone'];
      }

      // Get shipper location
      final shipperLocation = await supabase
          .from('shipper_profiles')
          .select('current_latitude, current_longitude')
          .eq('user_id', shipperId)
          .maybeSingle();

      if (shipperLocation != null) {
        final lat = (shipperLocation['current_latitude'] as num?)?.toDouble();
        final lon = (shipperLocation['current_longitude'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          _shipperLocation = LatLng(lat, lon);
        }
      }
    } catch (e) {
      print('Error loading shipper info: $e');
    }
  }

  void _startShipperLocationUpdates() {
    // Update shipper location every 10 seconds if order is being delivered
    if (widget.order.status == OrderStatus.delivering &&
        widget.order.shipperId != null) {
      _shipperLocationTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _updateShipperLocation(),
      );
    }
  }

  Future<void> _updateShipperLocation() async {
    if (widget.order.shipperId == null) return;

    try {
      final supabase = SupabaseService();
      final shipperLocation = await supabase
          .from('shipper_profiles')
          .select('current_latitude, current_longitude')
          .eq('user_id', widget.order.shipperId!)
          .maybeSingle();

      if (shipperLocation != null) {
        final lat = (shipperLocation['current_latitude'] as num?)?.toDouble();
        final lon = (shipperLocation['current_longitude'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          setState(() {
            _shipperLocation = LatLng(lat, lon);
          });
          _loadRoute(); // Update route with new shipper location
        }
      }
    } catch (e) {
      print('Error updating shipper location: $e');
    }
  }

  Future<void> _loadRoute() async {
    if (_shipperLocation == null || _customerLocation == null) return;

    try {
      final route = await RoutingService().getRoute(
        _shipperLocation!,
        _customerLocation!,
      );
      if (route != null && route.isNotEmpty) {
        setState(() {
          _routePoints = route;
        });
      }
    } catch (e) {
      print('Error loading route: $e');
    }
  }

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đơn hàng #${widget.order.id.length >= 6 ? widget.order.id.substring(widget.order.id.length - 6) : widget.order.id}',
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadOrderDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map showing shipper and restaurant location
                    _buildMap(),

                    // Order status
                    _buildStatusSection(),

                    // Restaurant info
                    _buildRestaurantInfo(),

                    // Shipper info (if assigned)
                    if (widget.order.shipperId != null) _buildShipperInfo(),

                    // Delivery address
                    _buildDeliveryAddress(),

                    // Order items
                    _buildOrderItems(),

                    // Order summary
                    _buildOrderSummary(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMap() {
    // Check if we have any locations to show
    final hasLocations =
        _restaurantLocation != null ||
        _shipperLocation != null ||
        _customerLocation != null;

    if (!hasLocations) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Chưa có thông tin vị trí',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 280,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _shipperLocation ??
                  _restaurantLocation ??
                  _customerLocation ??
                  const LatLng(16.0544, 108.2022), // Default: Da Nang
              initialZoom: 14,
              onMapReady: () => _fitMapBounds(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mobile',
              ),

              // Route polyline
              if (_routePoints != null && _routePoints!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints!,
                      strokeWidth: 4,
                      color: primaryColor,
                    ),
                  ],
                ),

              // Markers
              MarkerLayer(
                markers: [
                  // Restaurant marker
                  if (_restaurantLocation != null)
                    Marker(
                      point: _restaurantLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                  // Shipper marker
                  if (_shipperLocation != null)
                    Marker(
                      point: _shipperLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delivery_dining,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                  // Customer marker (delivery location)
                  if (_customerLocation != null)
                    Marker(
                      point: _customerLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Legend
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_restaurantLocation != null)
                    _buildLegendItem(Colors.orange, 'Nhà hàng'),
                  if (_shipperLocation != null)
                    _buildLegendItem(Colors.blue, 'Shipper'),
                  if (_customerLocation != null)
                    _buildLegendItem(Colors.green, 'Địa chỉ giao'),
                ],
              ),
            ),
          ),

          // Refresh button
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: primaryColor),
                onPressed: _loadOrderDetails,
                tooltip: 'Cập nhật vị trí',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  void _fitMapBounds() {
    final points = <LatLng>[
      if (_restaurantLocation != null) _restaurantLocation!,
      if (_shipperLocation != null) _shipperLocation!,
      if (_customerLocation != null) _customerLocation!,
    ];

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trạng thái đơn hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildStatusChip(widget.order.status),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusProgress(),
          const SizedBox(height: 8),
          Text(
            'Đặt lúc: ${_formatDate(widget.order.createdAt)}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderStatus.pending:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Chờ xác nhận';
        break;
      case OrderStatus.confirmed:
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        text = 'Đã xác nhận';
        break;
      case OrderStatus.preparing:
        bgColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        text = 'Đang chuẩn bị';
        break;
      case OrderStatus.readyForPickup:
        bgColor = Colors.teal.withOpacity(0.1);
        textColor = Colors.teal;
        text = 'Sẵn sàng giao';
        break;
      case OrderStatus.delivering:
        bgColor = primaryColor.withOpacity(0.1);
        textColor = primaryColor;
        text = 'Đang giao';
        break;
      case OrderStatus.delivered:
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        text = 'Đã giao';
        break;
      case OrderStatus.cancelled:
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildStatusProgress() {
    double progress;
    switch (widget.order.status) {
      case OrderStatus.pending:
        progress = 0.1;
        break;
      case OrderStatus.confirmed:
        progress = 0.25;
        break;
      case OrderStatus.preparing:
        progress = 0.4;
        break;
      case OrderStatus.readyForPickup:
        progress = 0.6;
        break;
      case OrderStatus.delivering:
        progress = 0.8;
        break;
      case OrderStatus.delivered:
        progress = 1.0;
        break;
      case OrderStatus.cancelled:
        progress = 0.0;
        break;
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          color: widget.order.status == OrderStatus.cancelled
              ? Colors.red
              : primaryColor,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đặt hàng',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              'Chuẩn bị',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              'Giao hàng',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              'Hoàn thành',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhà hàng',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _restaurantName ?? 'Đang tải...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_restaurantAddress != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _restaurantAddress!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
          if (_restaurantPhone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _restaurantPhone!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShipperInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shipper',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _shipperName ?? 'Đang tìm shipper...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_shipperPhone != null)
                IconButton(
                  onPressed: () {
                    // TODO: Call shipper
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gọi shipper: $_shipperPhone')),
                    );
                  },
                  icon: const Icon(Icons.phone, color: primaryColor),
                ),
            ],
          ),
          if (_shipperPhone != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _shipperPhone!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
          if (widget.order.status == OrderStatus.delivering) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: primaryColor),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Shipper đang trên đường giao hàng đến bạn',
                      style: TextStyle(fontSize: 13, color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.order.deliveryAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (widget.order.items.isEmpty)
            const Text('Không có món hàng')
          else
            ...widget.order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.foodName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${_formatPrice(item.price)} đ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_formatPrice(item.price * item.quantity)} đ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Phương thức thanh toán'),
              Text(
                widget.order.paymentMethod == 'cash'
                    ? 'Tiền mặt'
                    : widget.order.paymentMethod,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_formatPrice(widget.order.totalAmount)} đ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          if (widget.order.note != null && widget.order.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ghi chú: ${widget.order.note}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
