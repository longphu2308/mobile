import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DeliveryMapWidget extends StatefulWidget {
  final LatLng? shipperLocation;
  final LatLng? restaurantLocation;
  final LatLng? customerLocation;
  final bool showRoute;

  const DeliveryMapWidget({
    super.key,
    this.shipperLocation,
    this.restaurantLocation,
    this.customerLocation,
    this.showRoute = false,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
    });
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
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.shipperLocation ??
            widget.restaurantLocation ??
            widget.customerLocation ??
            const LatLng(10.762622, 106.660172), // Default: Saigon
        initialZoom: 13,
        minZoom: 5,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.mobile',
          maxZoom: 19,
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
    );
  }
}
