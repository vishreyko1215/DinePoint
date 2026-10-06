import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/geocoding_service.dart';
import '../services/restaurant_service.dart';
import 'midpoint_result_screen.dart';

class MidpointScreen extends StatefulWidget {
  const MidpointScreen({super.key});

  @override
  State<MidpointScreen> createState() => _MidpointScreenState();
}

class _MidpointScreenState extends State<MidpointScreen> {
  final List<String?> _selectedAreas = [null, null];

  final List<String> _bangaloreAreas = [
    'Indiranagar',
    'Whitefield',
    'Koramangala',
    'HSR Layout',
    'Jayanagar',
    'Church Street',
    'BTM Layout',
    'MG Road',
    'Malleshwaram',
    'Yelahanka',
    'Hebbal',
    'Rajajinagar',
    'Electronic City',
  ];

  final GeocodingService _geocodingService = GeocodingService();
  final RestaurantService _restaurantService = RestaurantService();
  bool _isLoading = false;

  void _addLocationField() {
    setState(() {
      _selectedAreas.add(null);
    });
  }

  void _removeLocationField(int index) {
    if (_selectedAreas.length > 2) {
      setState(() {
        _selectedAreas.removeAt(index);
      });
    }
  }

  Future<void> _findMidpoint() async {
    // Validate inputs
    final inputs = _selectedAreas.whereType<String>().toList();
    if (inputs.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 locations')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    List<LatLng> coordinates = [];
    List<String> validNames = [];
    
    // Geocode each input
    for (var address in inputs) {
      final loc = await _geocodingService.geocodeLocation(address);
      if (loc != null) {
        coordinates.add(loc);
        validNames.add(address);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not find location: $address')),
          );
        }
      }
    }

    if (coordinates.length >= 2) {
      final midpoint = _restaurantService.calculateMidpoint(coordinates);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MidpointResultScreen(
              midpoint: midpoint,
              origins: coordinates,
              originNames: validNames,
            ),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        foregroundColor: Colors.white,
        title: const Text('Find Midpoint', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFA8E6CF)),
                  SizedBox(height: 16),
                  Text("Calculating perfect meeting spot...", style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Where is everyone coming from?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select areas from the list to find restaurants perfectly in the middle.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  
                  // Location Inputs
                  ...List.generate(_selectedAreas.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8E6CF).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(color: Color(0xFFA8E6CF), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: const Color(0xFF1B1B2F),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedAreas[index],
                                dropdownColor: const Color(0xFF1B1B2F),
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA8E6CF)),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                hint: const Text(
                                  "Select Area",
                                  style: TextStyle(color: Colors.white38),
                                ),
                                items: _bangaloreAreas.map((area) {
                                  return DropdownMenuItem<String>(
                                    value: area,
                                    child: Text(area),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAreas[index] = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (_selectedAreas.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                              onPressed: () => _removeLocationField(index),
                            ),
                        ],
                      ),
                    );
                  }),

                  TextButton.icon(
                    onPressed: _addLocationField,
                    icon: const Icon(Icons.add, color: Color(0xFFA8E6CF)),
                    label: const Text("Add another location", style: TextStyle(color: Color(0xFFA8E6CF))),
                  ),
                  
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _findMidpoint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Find Midpoint Restaurants", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
