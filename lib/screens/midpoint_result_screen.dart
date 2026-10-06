import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import 'restaurant_detail_screen.dart';

class MidpointResultScreen extends StatefulWidget {
  final LatLng midpoint;
  final List<LatLng> origins;
  final List<String> originNames;

  const MidpointResultScreen({
    super.key,
    required this.midpoint,
    required this.origins,
    required this.originNames,
  });

  @override
  State<MidpointResultScreen> createState() => _MidpointResultScreenState();
}

class _MidpointResultScreenState extends State<MidpointResultScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await _restaurantService.findRestaurantsNearMidpoint(widget.midpoint, limit: 5);
    setState(() {
      _restaurants = results;
      _isLoading = false;
    });
  }

  void _shareInvite() {
    if (_restaurants.isEmpty) return;
    
    final buffer = StringBuffer();
    buffer.writeln("🍻 DinePoint Meeting Invite! 🍔");
    buffer.writeln("Hey! I calculated our perfect midpoint, and here are the top suggested restaurants to meet at:");
    for (var i = 0; i < _restaurants.length && i < 5; i++) {
      final r = _restaurants[i];
      buffer.writeln("- ${r.name} (${r.cuisine.isNotEmpty ? r.cuisine : r.type}) in ${r.area} [★ ${r.rating}]");
    }
    buffer.writeln("\nSent via DinePoint App 📍");

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✨ Midpoint Invite copied to Clipboard! Share it with your friends! ✨"),
        backgroundColor: Color(0xFFFF6B6B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate Origin Markers with labels 1, 2, 3...
    final originMarkers = List.generate(widget.origins.length, (index) {
      final origin = widget.origins[index];
      final name = widget.originNames[index];
      return Marker(
        point: origin,
        width: 40,
        height: 40,
        child: Tooltip(
          message: name,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B2F),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA8E6CF), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA8E6CF).withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Color(0xFFA8E6CF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      );
    });

    // Glowing Midpoint Marker
    final midpointMarker = Marker(
      point: widget.midpoint,
      width: 50,
      height: 50,
      child: Tooltip(
        message: "Calculated Midpoint",
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(
            Icons.stars_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );

    // Restaurant Recommendation Markers
    final restaurantMarkers = _restaurants.map((r) {
      return Marker(
        point: LatLng(r.lat, r.lon),
        width: 36,
        height: 36,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantDetailScreen(restaurant: r),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA8E6CF), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Color(0xFF1B1B2F),
              size: 16,
            ),
          ),
        ),
      );
    }).toList();

    // Dotted lines connecting each origin to the calculated midpoint
    final polylines = widget.origins.map((origin) {
      return Polyline(
        points: [origin, widget.midpoint],
        color: const Color(0xFFA8E6CF).withOpacity(0.5),
        strokeWidth: 3.0,
      );
    }).toList();

    final allMarkers = [
      midpointMarker,
      ...originMarkers,
      ...restaurantMarkers,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        foregroundColor: Colors.white,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Suggested Places', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFFA8E6CF)),
            tooltip: 'Share Invite',
            onPressed: _shareInvite,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA8E6CF)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Map view showcasing origins, midpoint and polylines
                SizedBox(
                  height: 280,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: widget.midpoint,
                        initialZoom: 12.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.dinepoint.app',
                        ),
                        PolylineLayer(polylines: polylines),
                        MarkerLayer(markers: allMarkers),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Restaurants near your midpoint",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: _restaurants.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final r = _restaurants[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailScreen(restaurant: r),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8E6CF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          r.rating,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      r.cuisine.isNotEmpty ? r.cuisine : r.type,
                                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${_restaurantService.calculateDistance(widget.midpoint, LatLng(r.lat, r.lon)).toStringAsFixed(1)} km from midpoint",
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
