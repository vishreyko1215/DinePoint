import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import 'restaurant_detail_screen.dart';
import 'filter_screen.dart';
import '../services/favorites_service.dart';
import 'favorites_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final FavoritesService _favoritesService = FavoritesService();
  
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  Set<String> _favoriteIds = {};
  Map<String, dynamic> _activeFilters = {};
  
  bool _isLoading = true;
  String _searchText = "";
  String _userName = "User";
  
  // Note: Selected filters will be managed via FilterScreen eventually.
  // For now, simple text search applies.

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final restaurants = await _restaurantService.getRestaurants();
    final favs = await _favoritesService.getFavorites();
    final user = await AuthService().getCurrentUser();
    
    // Shuffle restaurants to show in a random order initially
    restaurants.shuffle();
    
    setState(() {
      _allRestaurants = restaurants;
      _filteredRestaurants = List.from(restaurants);
      _favoriteIds = favs.toSet();
      if (user != null && user.containsKey('name')) {
        _userName = user['name']!;
      }
      _isLoading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final favs = await _favoritesService.getFavorites();
    setState(() {
      _favoriteIds = favs.toSet();
    });
  }

  Future<void> _toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      await _favoritesService.removeFavorite(id);
      setState(() {
        _favoriteIds.remove(id);
      });
      print('Removed favorite $id');
    } else {
      await _favoritesService.addFavorite(id);
      setState(() {
        _favoriteIds.add(id);
      });
      print('Added favorite $id');
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B2F),
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to log out of DinePoint?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredRestaurants = _allRestaurants.where((r) {
        // Text Search
        if (_searchText.isNotEmpty) {
          if (!r.name.toLowerCase().contains(_searchText.toLowerCase()) && 
              !r.area.toLowerCase().contains(_searchText.toLowerCase()) &&
              !r.cuisine.toLowerCase().contains(_searchText.toLowerCase())) {
            return false;
          }
        }
        
        // Cuisines
        final cuisines = _activeFilters['cuisines'] as List<String>? ?? [];
        if (cuisines.isNotEmpty) {
           bool matchesCuisine = cuisines.any((c) => r.cuisine.toLowerCase().contains(c.toLowerCase()) || r.type.toLowerCase().contains(c.toLowerCase()));
           if (!matchesCuisine) return false;
        }
        
        // Areas
        final areas = _activeFilters['areas'] as List<String>? ?? [];
        if (areas.isNotEmpty) {
           bool matchesArea = areas.any((a) => r.area.toLowerCase().contains(a.toLowerCase()));
           if (!matchesArea) return false;
        }

        // Rating
        final ratingStr = _activeFilters['rating'] as String? ?? '';
        if (ratingStr.isNotEmpty) {
           double minRating = 0;
           if (ratingStr == '4.5+') minRating = 4.5;
           else if (ratingStr == '4+') minRating = 4.0;
           else if (ratingStr == '3+') minRating = 3.0;
           
           double rRating = double.tryParse(r.rating) ?? 0.0;
           if (rRating < minRating) return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFA8E6CF),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading dining locator...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    // HEADER SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "DinePoint",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Hello, $_userName • Bangalore",
                                style: const TextStyle(
                                  color: Color(0xFFA8E6CF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                                ).then((_) => _loadFavorites());
                              },
                              icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                            ),
                            IconButton(
                              onPressed: _showLogoutConfirmation,
                              icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 26),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SEARCH BAR & FILTER
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8E6CF).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                _searchText = value;
                                _applyFilters();
                              },
                              style: const TextStyle(color: Colors.black87),
                              decoration: const InputDecoration(
                                hintText: "Search restaurants...",
                                hintStyle: TextStyle(color: Colors.black54),
                                prefixIcon: Icon(Icons.search, color: Colors.black54),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 24,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),

                    // FILTER BUTTON ROW
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => FilterScreen(initialFilters: _activeFilters))
                          );
                          if (result != null) {
                            _activeFilters = result as Map<String, dynamic>;
                            _applyFilters();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8E6CF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter_list, size: 16, color: Colors.black),
                              SizedBox(width: 6),
                              Text(
                                "Filters",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // RESTAURANT LIST
                    Expanded(
                      child: _buildListView(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildListView() {
    if (_filteredRestaurants.isEmpty) {
      return const Center(
        child: Text(
          "No restaurants match your search or filter",
          style: TextStyle(color: Colors.white54, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredRestaurants.length,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, index) {
        final r = _filteredRestaurants[index];

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
              color: const Color(0xFFA8E6CF), // Teal/mint card
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              r.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleFavorite(r.id),
                            child: Icon(
                              _favoriteIds.contains(r.id) ? Icons.favorite : Icons.favorite_border,
                              size: 24,
                              color: _favoriteIds.contains(r.id) ? Colors.redAccent : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            r.rating,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.cuisine.isNotEmpty ? r.cuisine : r.type,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              r.area,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
