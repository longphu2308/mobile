import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/services/routing_service.dart';

enum RouteDestination { restaurant, customer }

class DeliveryMapWidget extends StatefulWidget {
  final LatLng? shipperLocation;
  final LatLng? restaurantLocation;
  final LatLng? customerLocation;
  final RouteDestination? activeRoute;
  final ValueChanged<RouteDestination?>? onRouteChanged;

  const DeliveryMapWidget({
    super.key,
    this.shipperLocation,
    this.restaurantLocation,
    this.customerLocation,
    this.activeRoute,
    this.onRouteChanged,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  final MapController _mapController = MapController();
  List<LatLng>? _routePoints;
  bool _isLoadingRoute = false;
  bool _hasZoomedToShipper = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  @override
  void didUpdateWidget(DeliveryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Zoom to shipper location when it's first loaded
    if (!_hasZoomedToShipper && 
        oldWidget.shipperLocation == null && 
        widget.shipperLocation != null) {
      print('🎯 Zooming to shipper location: ${widget.shipperLocation}');
      _mapController.move(widget.shipperLocation!, 15);
      _hasZoomedToShipper = true;
    }
    
    if (widget.activeRoute != oldWidget.activeRoute) {
      _fetchRoute();
    }
  }

  void _initializeMap() {
    if (widget.shipperLocation != null) {
      // Zoom to shipper location by default
      _mapController.move(widget.shipperLocation!, 15);
    } else {
      _fitBounds();
    }
    if (widget.activeRoute != null) {
      _fetchRoute();
    }
  }

  Future<void> _fetchRoute() async {
    print('🗺️ _fetchRoute called');
    if (widget.shipperLocation == null) {
      print('❌ Shipper location is null, cannot fetch route');
      return;
    }
    
    LatLng? destination;
    if (widget.activeRoute == RouteDestination.restaurant) {
      destination = widget.restaurantLocation;
      print('📍 Destination: Restaurant at $destination');
    } else if (widget.activeRoute == RouteDestination.customer) {
      destination = widget.customerLocation;
      print('📍 Destination: Customer at $destination');
    }

    if (destination == null) {
      print('❌ Destination is null, cannot fetch route');
      return;
    }

    setState(() => _isLoadingRoute = true);
    print('⏳ Fetching route from ${widget.shipperLocation} to $destination');
    
    final route = await RoutingService().getRoute(widget.shipperLocation!, destination);
    print('📦 Route received: ${route?.length ?? 0} points');
    
    setState(() {
      _routePoints = route;
      _isLoadingRoute = false;
    });

    // Fit bounds to show full route
    if (_routePoints != null && _routePoints!.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(_routePoints!);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  void _fitBounds() {
    final points = <LatLng>[
      if (widget.shipperLocation != null) widget.shipperLocation!,
      if (widget.restaurantLocation != null) widget.restaurantLocation!,
      if (widget.customerLocation != null) widget.customerLocation!,
    ];

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.shipperLocation ??
                widget.restaurantLocation ??
                widget.customerLocation ??
                const LatLng(10.762622, 106.660172), // Default: Saigon
            initialZoom: 15,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mobile',
              maxZoom: 19,
            ),
            // Route polyline
            if (_routePoints != null && _routePoints!.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints!,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Shipper marker (blue)
                if (widget.shipperLocation != null)
                  Marker(
                    point: widget.shipperLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.delivery_dining,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                // Restaurant marker (orange)
                if (widget.restaurantLocation != null)
                  Marker(
                    point: widget.restaurantLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                // Customer marker (green)
                if (widget.customerLocation != null)
                  Marker(
                    point: widget.customerLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ],
        ),
        // Loading indicator
        if (_isLoadingRoute)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Tính đường...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
