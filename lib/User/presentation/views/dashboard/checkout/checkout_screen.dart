import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/formatters.dart';
import 'package:mobile/User/presentation/controllers/cart_controller.dart';
import 'package:mobile/User/presentation/controllers/order_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/core/models/cart_model.dart';
import 'package:mobile/config/routes.dart';
import 'package:mobile/core/services/geocoding_service.dart';
import 'package:mobile/core/services/location_service.dart';
import 'package:mobile/core/services/routing_service.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'cash';
  String _selectedDeliveryMethod = 'fast'; // 'fast' hoặc 'economy'
  double _deliveryFee = 0;
  double _distanceKm = 0;

  // Location data
  LatLng? _userLocation;
  LatLng? _restaurantLocation;
  List<LatLng>? _routePoints;
  bool _isLoadingLocation = true;
  bool _isCalculatingFee = false;

  final MapController _mapController = MapController();

  final List<_PaymentOption> _paymentOptions = const [
    _PaymentOption(
      key: 'cash',
      label: 'Tiền mặt',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFFFFB347),
    ),
    _PaymentOption(
      key: 'card',
      label: 'Thẻ',
      icon: Icons.credit_card,
      color: Color(0xFF6C63FF),
    ),
    _PaymentOption(
      key: 'bank',
      label: 'Chuyển khoản',
      icon: Icons.account_balance,
      color: Color(0xFFFF5E95),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLocationsAndCalculateFee();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationsAndCalculateFee() async {
    setState(() {
      _isLoadingLocation = true;
      _isCalculatingFee = true;
    });

    try {
      final cartController = Get.find<CartController>();
      final authController = Get.find<AuthController>();

      // Get user address
      final userAddress = authController.address;
      if (userAddress == null || userAddress.isEmpty) {
        setState(() {
          _isLoadingLocation = false;
          _isCalculatingFee = false;
        });
        return;
      }

      // Geocode user address
      final userCoords = await GeocodingService().getCoordinatesFromAddress(
        userAddress,
      );
      if (userCoords == null) {
        setState(() {
          _isLoadingLocation = false;
          _isCalculatingFee = false;
        });
        return;
      }
      _userLocation = userCoords;

      // Get restaurant location
      final restaurantId = cartController.currentRestaurantId;
      if (restaurantId != null && restaurantId.isNotEmpty) {
        final supabase = SupabaseService().client;
        final restaurantData = await supabase
            .from('restaurants')
            .select('latitude, longitude')
            .eq('restaurant_id', restaurantId)
            .maybeSingle();

        if (restaurantData != null) {
          final lat = (restaurantData['latitude'] as num?)?.toDouble();
          final lon = (restaurantData['longitude'] as num?)?.toDouble();
          if (lat != null && lon != null) {
            _restaurantLocation = LatLng(lat, lon);

            // Calculate distance
            _distanceKm = LocationService().calculateDistance(
              _userLocation!.latitude,
              _userLocation!.longitude,
              lat,
              lon,
            );

            // Calculate delivery fee based on selected method
            if (_selectedDeliveryMethod == 'fast') {
              // Giao hàng nhanh: km * 3000 * 1.5
              _deliveryFee = _distanceKm * 3000 * 1.5;
            } else {
              // Giao hàng tiết kiệm: km * 3000
              _deliveryFee = _distanceKm * 3000;
            }

            // Load route for map
            if (_selectedDeliveryMethod == 'fast' ||
                _selectedDeliveryMethod == 'economy') {
              await _loadRoute();
            }
          }
        }
      }

      // Fit map bounds
      if (_userLocation != null && _restaurantLocation != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            final bounds = LatLngBounds.fromPoints([
              _userLocation!,
              _restaurantLocation!,
            ]);
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50),
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Error loading locations: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
        _isCalculatingFee = false;
      });
    }
  }

  Future<void> _loadRoute() async {
    if (_userLocation == null || _restaurantLocation == null) return;

    try {
      final route = await RoutingService().getRoute(
        _userLocation!,
        _restaurantLocation!,
      );
      if (route != null && mounted) {
        setState(() {
          _routePoints = route;
        });
      }
    } catch (e) {
      print('Error loading route: $e');
    }
  }

  void _onDeliveryMethodChanged(String method) {
    setState(() {
      _selectedDeliveryMethod = method;
      // Recalculate fee based on method
      if (method == 'fast') {
        // Giao hàng nhanh: km * 3000 * 1.5
        _deliveryFee = _distanceKm * 3000 * 1.5;
      } else if (method == 'economy') {
        // Giao hàng tiết kiệm: km * 3000
        _deliveryFee = _distanceKm * 3000;
      }
    });
    if (_userLocation != null && _restaurantLocation != null) {
      _loadRoute();
    }
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
      body: GetBuilder<CartController>(
        builder: (cartController) {
          final authController = Get.find<AuthController>();
          final orderController = Get.find<OrderController>();
          if (cartController.items.isEmpty) {
            return const Center(child: Text('Giỏ hàng của bạn đang trống'));
          }

          final groupedItems = _groupItemsByRestaurant(cartController.items);
          final restaurantNames = groupedItems.keys.toList();
          final double totalWithDelivery =
              cartController.totalPrice +
              ((_selectedDeliveryMethod == 'fast' ||
                      _selectedDeliveryMethod == 'economy')
                  ? _deliveryFee
                  : 0);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AddressCard(
                        name: authController.fullName ?? 'Chưa có tên',
                        address: authController.address ?? 'Chưa có địa chỉ',
                        phone: authController.phone ?? 'Chưa có số điện thoại',
                      ),
                      const SizedBox(height: 16),
                      // Map section
                      if (_isLoadingLocation)
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                        )
                      else if (_userLocation != null &&
                          _restaurantLocation != null)
                        _buildMap(),
                      const SizedBox(height: 16),
                      const Text(
                        'Phương thức giao hàng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DeliverySelector(
                        selectedMethod: _selectedDeliveryMethod,
                        deliveryFee: _deliveryFee,
                        distanceKm: _distanceKm,
                        isCalculating: _isCalculatingFee,
                        onChanged: _onDeliveryMethodChanged,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Phương thức thanh toán',
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
                        'Tóm tắt đơn hàng',
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
                        label: 'Tạm tính',
                        value: formatPrice(cartController.totalPrice),
                      ),
                      const SizedBox(height: 4),
                      _SummaryRow(
                        label: 'Phí vận chuyển',
                        value:
                            (_selectedDeliveryMethod == 'fast' ||
                                _selectedDeliveryMethod == 'economy')
                            ? formatPrice(_deliveryFee)
                            : 'Miễn phí',
                      ),
                      if (_distanceKm > 0) ...[
                        const SizedBox(height: 4),
                        _SummaryRow(
                          label: 'Khoảng cách',
                          value: '${_distanceKm.toStringAsFixed(1)} km',
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng cộng',
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
                                    'Vui lòng cập nhật địa chỉ trước khi đặt hàng',
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
                            'Đặt hàng',
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

  Widget _buildMap() {
    if (_userLocation == null || _restaurantLocation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _userLocation!, initialZoom: 13),
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
              // User location marker
              Marker(
                point: _userLocation!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.home, color: Colors.white, size: 20),
                ),
              ),
              // Restaurant location marker
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
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  Future<void> _completeOrder(
    BuildContext context,
    CartController cartController,
    OrderController orderController,
    double totalPrice,
    String deliveryAddress,
  ) async {
    final items = List<CartItemModel>.from(cartController.items);
    final restaurantId = cartController.currentRestaurantId ?? '';
    final paymentMethod = _selectedPaymentMethod;

    // Geocode delivery address to get coordinates
    double? deliveryLatitude;
    double? deliveryLongitude;

    print('🌍 Geocoding delivery address: $deliveryAddress');
    final coordinates = await GeocodingService().getCoordinatesFromAddress(
      deliveryAddress,
    );
    if (coordinates != null) {
      deliveryLatitude = coordinates.latitude;
      deliveryLongitude = coordinates.longitude;
      print('✅ Geocoded: lat=$deliveryLatitude, lon=$deliveryLongitude');
    } else {
      print(
        '⚠️ Could not geocode address, order will be created without coordinates',
      );
    }

    print(
      '📍 Creating order with delivery location: lat=$deliveryLatitude, lon=$deliveryLongitude',
    );

    orderController
        .createOrder(
          items,
          totalPrice,
          restaurantId: restaurantId,
          deliveryAddress: deliveryAddress,
          paymentMethod: paymentMethod,
          deliveryLatitude: deliveryLatitude,
          deliveryLongitude: deliveryLongitude,
          note:
              'Phương thức giao hàng: ${_selectedDeliveryMethod == 'fast' ? 'Giao hàng nhanh' : 'Giao hàng tiết kiệm'}',
        )
        .then((success) {
          if (!context.mounted) return;
          if (success) {
            cartController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đặt hàng thành công!'),
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
                      'Đặt hàng thất bại. Vui lòng thử lại.',
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

  const _AddressCard({
    required this.name,
    required this.address,
    required this.phone,
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
          const Text(
            'Thông tin địa chỉ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
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

class _DeliverySelector extends StatelessWidget {
  final String selectedMethod;
  final double deliveryFee;
  final double distanceKm;
  final bool isCalculating;
  final ValueChanged<String> onChanged;

  const _DeliverySelector({
    required this.selectedMethod,
    required this.deliveryFee,
    required this.distanceKm,
    required this.isCalculating,
    required this.onChanged,
  });

  double _calculateFeeForMethod(String method) {
    if (distanceKm == 0 || isCalculating) return 0;
    if (method == 'fast') {
      // Giao hàng nhanh: km * 3000 * 1.5
      return distanceKm * 3000 * 1.5;
    } else {
      // Giao hàng tiết kiệm: km * 3000
      return distanceKm * 3000;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DeliveryTile(
          title: 'Giao hàng nhanh',
          subtitle: isCalculating
              ? 'Đang tính...'
              : '${formatPrice(_calculateFeeForMethod('fast'))} đ (${distanceKm.toStringAsFixed(1)} km)',
          icon: Icons.flash_on,
          isSelected: selectedMethod == 'fast',
          onTap: () => onChanged('fast'),
        ),
        const SizedBox(height: 12),
        _DeliveryTile(
          title: 'Giao hàng tiết kiệm',
          subtitle: isCalculating
              ? 'Đang tính...'
              : '${formatPrice(_calculateFeeForMethod('economy'))} đ (${distanceKm.toStringAsFixed(1)} km)',
          icon: Icons.local_shipping,
          isSelected: selectedMethod == 'economy',
          onTap: () => onChanged('economy'),
        ),
      ],
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primaryColor : blackColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? primaryColor : greyColor,
                    ),
                  ),
                ],
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
