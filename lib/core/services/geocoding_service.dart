import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  /// Get coordinates from address using OpenStreetMap Nominatim (FREE)
  /// No API key required
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      print('🌍 Geocoding address: $address');
      
      // Add "Vietnam" to address for better results
      final searchAddress = address.contains('Việt Nam') || address.contains('Vietnam')
          ? address
          : '$address, Vietnam';
      
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(searchAddress)}&'
        'format=json&'
        'limit=1&'
        'addressdetails=1'
      );

      print('📡 Geocoding URL: $url');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FoodDeliveryApp/1.0', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        
        if (results.isNotEmpty) {
          final location = results[0];
          final lat = double.parse(location['lat']);
          final lon = double.parse(location['lon']);
          
          print('✅ Geocoding successful: lat=$lat, lon=$lon');
          print('📍 Display name: ${location['display_name']}');
          
          return LatLng(lat, lon);
        } else {
          print('❌ No results found for address: $address');
        }
      } else {
        print('❌ Geocoding API error: ${response.statusCode}');
      }
      
      return null;
    } catch (e) {
      print('❌ Geocoding error: $e');
      return null;
    }
  }

  /// Reverse geocoding - get address from coordinates
  Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'lat=${coordinates.latitude}&'
        'lon=${coordinates.longitude}&'
        'format=json'
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FoodDeliveryApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      }
      
      return null;
    } catch (e) {
      print('❌ Reverse geocoding error: $e');
      return null;
    }
  }
}
