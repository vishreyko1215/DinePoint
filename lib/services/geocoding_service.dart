import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  // Hardcoded highly accurate coordinates for Bangalore areas to ensure 100% uptime and speed
  static const Map<String, LatLng> _predefinedCoordinates = {
    'Indiranagar': LatLng(12.9719, 77.6412),
    'Whitefield': LatLng(12.9698, 77.7500),
    'Koramangala': LatLng(12.9352, 77.6244),
    'HSR Layout': LatLng(12.9101, 77.6450),
    'Jayanagar': LatLng(12.9308, 77.5830),
    'Church Street': LatLng(12.9747, 77.6039),
    'BTM Layout': LatLng(12.9166, 77.6101),
    'MG Road': LatLng(12.9738, 77.6119),
    'Malleshwaram': LatLng(12.9961, 77.5702),
    'Yelahanka': LatLng(13.1007, 77.5963),
    'Hebbal': LatLng(13.0358, 77.5970),
    'Rajajinagar': LatLng(12.9897, 77.5552),
    'Electronic City': LatLng(12.8452, 77.6630),
  };

  // Nominatim OpenStreetMap API for Geocoding with local cache fallback
  Future<LatLng?> geocodeLocation(String address) async {
    final cleanAddress = address.trim();
    
    // Check predefined list first
    if (_predefinedCoordinates.containsKey(cleanAddress)) {
      return _predefinedCoordinates[cleanAddress];
    }
    
    // Case-insensitive check just in case
    for (var entry in _predefinedCoordinates.entries) {
      if (entry.key.toLowerCase() == cleanAddress.toLowerCase()) {
        return entry.value;
      }
    }

    // Adding Bangalore to query to scope it mostly within our data bounds
    final query = '$cleanAddress, Bangalore, India';
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=1');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'DinePointApp/1.0 (Contact: local@example.com)' // Required by Nominatim policy
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      } else {
        print("Geocoding failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    
    return null;
  }
}
