import 'dart:math';

import 'package:mobile/core/services/supabase/supabase_service.dart';

class OrderItem {
  final String name;
  final int qty;
  final double price;

  OrderItem({required this.name, required this.qty, required this.price});

  double get total => qty * price;

  String get priceString => '${price.toInt()} VND';
}

class ShipperOrder {
  final String id;
  final String customerName;
  final String address;
  final double distanceKm;
  final String status;
  final double total;
  final List<OrderItem> items;
  final String eta;
  final String? restaurantName;
  final String? restaurantAddress;
  final double? fee;
  final String? customerPhone;
  final String? restaurantPhone;
  final String? restaurantId;

  ShipperOrder({
    required this.id,
    required this.customerName,
    required this.address,
    required this.distanceKm,
    required this.status,
    required this.total,
    required this.items,
    required this.eta,
    this.restaurantName,
    this.restaurantAddress,
    this.fee,
    this.customerPhone,
    this.restaurantPhone,
    this.restaurantId,
  });

  /// Fetch assigned orders for the current shipper (or provided `shipperId`).
  ///
  /// This replaces previous mock data and loads data from `orders`,
  /// `order_items`, `restaurants` and `user_profiles` tables.
  static Future<List<ShipperOrder>> fetchAssignedOrders({String? shipperId}) async {
    final supabase = SupabaseService();
    final currentShipperId = shipperId ?? supabase.userId;
    if (currentShipperId == null) return [];

    try {
      final orders = await supabase.from('orders').select().eq('shipper_id', currentShipperId);

      // Try to get shipper current location for distance calculation
      double? shipperLat;
      double? shipperLon;
      try {
        final shipperProfile = await supabase
            .from('shipper_profiles')
            .select()
            .eq('user_id', currentShipperId)
            .maybeSingle();
        if (shipperProfile != null) {
          shipperLat = (shipperProfile['current_latitude'] as num?)?.toDouble();
          shipperLon = (shipperProfile['current_longitude'] as num?)?.toDouble();
        }
      } catch (_) {}

      final List<ShipperOrder> result = [];

      for (final o in (orders as List)) {
        final orderId = o['order_id'] as String? ?? '';
        // DEBUG: log order id to help trace missing items
        print('ShipperOrder.fetchAssignedOrders: orderId=$orderId');

        // Items for order - try direct table first
        dynamic itemsData = await supabase.from('order_items').select().eq('order_id', orderId);
        print('ShipperOrder.fetchAssignedOrders: orderId=$orderId itemsData=${(itemsData as List?)?.length ?? 0}');

        // If no items returned, try fetching via parent orders with embedded relation
        if (itemsData == null || (itemsData as List).isEmpty) {
          try {
            final orderWithItems = await supabase.from('orders').select('order_items(*)').eq('order_id', orderId).maybeSingle();
            final embedded = (orderWithItems != null && orderWithItems['order_items'] != null)
                ? (orderWithItems['order_items'] as List<dynamic>)
                : <dynamic>[];
            if (embedded.isNotEmpty) {
              itemsData = embedded;
              print('ShipperOrder.fetchAssignedOrders: fetched items via orders relation, count=${embedded.length}');
            }
          } catch (e) {
            // ignore
          }
        }

        final items = (itemsData as List? ?? []).map((i) {
          final price = (i['price'] as num?)?.toDouble() ?? 0.0;
          return OrderItem(
            name: i['food_name'] ?? '',
            qty: (i['quantity'] as int?) ?? (i['quantity'] as num?)?.toInt() ?? 0,
            price: price,
          );
        }).toList();

        // Restaurant info
        Map<String, dynamic>? restaurant;
        try {
          restaurant = await supabase
              .from('restaurants')
              .select()
              .eq('restaurant_id', o['restaurant_id'])
              .maybeSingle();
        } catch (_) {
          restaurant = null;
        }

        // Customer profile
        Map<String, dynamic>? customerProfile;
        try {
          customerProfile = await supabase
              .from('user_profiles')
              .select()
              .eq('user_id', o['user_id'])
              .maybeSingle();
        } catch (_) {
          customerProfile = null;
        }

        final deliveryLat = (o['delivery_latitude'] as num?)?.toDouble();
        final deliveryLon = (o['delivery_longitude'] as num?)?.toDouble();

        double distanceKm = 0.0;
        if (shipperLat != null && shipperLon != null && deliveryLat != null && deliveryLon != null) {
          distanceKm = _distanceInKm(shipperLat, shipperLon, deliveryLat, deliveryLon);
        }

        final eta = distanceKm > 0 ? '${(distanceKm / 30 * 60).round()} mins' : '';

        final total = (o['total_amount'] as num?)?.toDouble() ?? 0.0;

        result.add(ShipperOrder(
          id: orderId,
          customerName: customerProfile != null ? (customerProfile['full_name'] ?? '') : '',
          address: o['delivery_address'] ?? '',
          distanceKm: distanceKm,
          status: o['status'] ?? '',
          total: total,
          items: items,
          eta: eta,
          restaurantName: restaurant != null ? (restaurant['name'] ?? '') : null,
          restaurantAddress: restaurant != null ? (restaurant['address'] ?? '') : null,
          fee: null,
          customerPhone: customerProfile != null ? (customerProfile['phone'] ?? '') : null,
          restaurantPhone: restaurant != null ? (restaurant['phone'] ?? '') : null,
          restaurantId: o['restaurant_id'] as String?,
        ));
      }

      return result;
    } catch (e) {
      print('Error fetching shipper orders: $e');
      return [];
    }
  }

  static double _distanceInKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  String? get feeString => fee == null ? null : '${fee!.toInt()} VND';
}
