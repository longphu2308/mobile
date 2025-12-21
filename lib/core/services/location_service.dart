import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile/core/services/supabase/supabase_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  /// Request location permission
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      final permission = await requestPermission();
      if (!permission) {
        print('Location permission denied');
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      return _currentPosition;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Start continuous location tracking (for shipper)
  Stream<Position> trackLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  /// Update shipper location to Supabase
  Future<void> updateShipperLocation(double lat, double lon) async {
    try {
      final supabase = SupabaseService();
      final uid = supabase.userId;
      if (uid == null) return;

      await supabase.from('shipper_profiles').update({
        'current_latitude': lat,
        'current_longitude': lon,
        'last_location_update': DateTime.now().toIso8601String(),
      }).eq('user_id', uid);
    } catch (e) {
      print('Error updating shipper location: $e');
    }
  }

  /// Calculate distance between two points (in km)
  double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon) / 1000;
  }
}
