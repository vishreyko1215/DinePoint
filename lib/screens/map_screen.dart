import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import 'restaurant_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final Restaurant? targetRestaurant;
  
  const MapScreen({super.key, this.targetRestaurant});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  Restaurant? _selectedMapRestaurant;

  @override
  void initState() {
    super.initState();
    _selectedMapRestaurant = widget.targetRestaurant;
    _loadData();
  }

  Future<void> _loadData() async {
    final restaurants = await _restaurantService.getRestaurants();
    setState(() {
      _restaurants = restaurants;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B1B2F),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFA8E6CF)),
        ),
      );
    }

    final LatLng mapCenter = widget.targetRestaurant != null
        ? LatLng(widget.targetRestaurant!.lat, widget.targetRestaurant!.lon)
        : (_restaurants.isNotEmpty
            ? LatLng(_restaurants.first.lat, _restaurants.first.lon)
            : const LatLng(12.9738, 77.6119));

    final markers = _restaurants.map((r) {
      final isSelected = _selectedMapRestaurant != null && _selectedMapRestaurant!.id == r.id;
      
      return Marker(
        point: LatLng(r.lat, r.lon),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedMapRestaurant = r;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            child: Icon(
              Icons.location_pin,
              color: isSelected ? Colors.black : const Color(0xFFFF6B6B),
              size: isSelected ? 48 : 36,
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        title: const Text('Map View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 12.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedMapRestaurant = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dinepoint.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          
          if (_selectedMapRestaurant != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: _buildMapSelectedCard(_selectedMapRestaurant!),
            ),
        ],
      ),
    );
  }

  Widget _buildMapSelectedCard(Restaurant r) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFA8E6CF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              r.imageUrl,
              height: 70,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 70,
                width: 70,
                color: Colors.grey.shade400,
                child: const Icon(Icons.restaurant, color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  r.area,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber.shade900, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      r.rating,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.type,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(restaurant: r),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
