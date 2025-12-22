import 'dart:async';
import 'package:mobile/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class ShipperTrackingService {
  static final ShipperTrackingService _instance = ShipperTrackingService._internal();
  factory ShipperTrackingService() => _instance;
  ShipperTrackingService._internal();

  StreamSubscription<Position>? _locationSubscription;
  Timer? _updateTimer;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  /// Start tracking shipper location
  Future<void> startTracking() async {
    if (_isTracking) return;

    final locationService = LocationService();
    
    // Request permission first
    final hasPermission = await locationService.requestPermission();
    if (!hasPermission) {
      print('Location permission denied');
      return;
    }

    _isTracking = true;
    Position? lastPosition;

    // Listen to location updates
    _locationSubscription = locationService.trackLocation().listen(
      (position) {
        lastPosition = position;
      },
      onError: (e) {
        print('Location tracking error: $e');
      },
    );

    // Update to Supabase every 10 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (lastPosition != null) {
        await locationService.updateShipperLocation(
          lastPosition!.latitude,
          lastPosition!.longitude,
        );
        print('Updated shipper location: ${lastPosition!.latitude}, ${lastPosition!.longitude}');
      }
    });

    print('Shipper tracking started');
  }

  /// Stop tracking shipper location
  void stopTracking() {
    _locationSubscription?.cancel();
    _updateTimer?.cancel();
    _isTracking = false;
    print('Shipper tracking stopped');
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
  }
}
