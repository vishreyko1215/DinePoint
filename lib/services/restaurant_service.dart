import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/restaurant.dart';
import 'database_helper.dart';

class RestaurantService {
  List<Restaurant> _cachedRestaurants = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Loads restaurants from the SQLite database
  Future<List<Restaurant>> getRestaurants() async {
    if (_cachedRestaurants.isNotEmpty) {
      return _cachedRestaurants;
    }

    try {
      final dbList = await _dbHelper.getAllRestaurants();
      _cachedRestaurants = dbList.map((item) => Restaurant.fromJson(item)).toList();
      return _cachedRestaurants;
    } catch (e) {
      print("❌ Error loading restaurants from DB: $e");
      return [];
    }
  }

  // Filter list by category and search text
  List<Restaurant> filter(List<Restaurant> restaurants, String query, String category) {
    return restaurants.where((r) {
      final matchesCategory = category == "All" || r.type.toLowerCase() == category.toLowerCase();
      final matchesSearch = r.name.toLowerCase().contains(query.toLowerCase()) ||
          r.area.toLowerCase().contains(query.toLowerCase()) ||
          r.address.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Calculate the geographical midpoint (centroid) of a list of coordinates
  LatLng calculateMidpoint(List<LatLng> locations) {
    if (locations.isEmpty) return const LatLng(0, 0);
    if (locations.length == 1) return locations.first;

    double x = 0;
    double y = 0;
    double z = 0;

    for (var loc in locations) {
      double lat = loc.latitude * pi / 180;
      double lon = loc.longitude * pi / 180;

      x += cos(lat) * cos(lon);
      y += cos(lat) * sin(lon);
      z += sin(lat);
    }

    int total = locations.length;
    x = x / total;
    y = y / total;
    z = z / total;

    double centralLon = atan2(y, x);
    double centralSquareRoot = sqrt(x * x + y * y);
    double centralLat = atan2(z, centralSquareRoot);

    return LatLng(centralLat * 180 / pi, centralLon * 180 / pi);
  }

  // Haversine formula to calculate distance between two coordinates in kilometers
  double calculateDistance(LatLng p1, LatLng p2) {
    const R = 6371; // Earth's radius in km
    double dLat = _deg2rad(p2.latitude - p1.latitude);
    double dLon = _deg2rad(p2.longitude - p1.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(p1.latitude)) * cos(_deg2rad(p2.latitude)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  // Get restaurants sorted by distance from a given midpoint
  Future<List<Restaurant>> findRestaurantsNearMidpoint(LatLng midpoint, {int limit = 10}) async {
    final all = await getRestaurants();
    
    // Create a copy of the list to sort
    List<Restaurant> sortedList = List.from(all);
    
    sortedList.sort((a, b) {
      final distA = calculateDistance(midpoint, LatLng(a.lat, a.lon));
      final distB = calculateDistance(midpoint, LatLng(b.lat, b.lon));
      return distA.compareTo(distB);
    });

    return sortedList.take(limit).toList();
  }
}
