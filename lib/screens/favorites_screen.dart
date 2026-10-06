import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../services/favorites_service.dart';
import 'restaurant_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final FavoritesService _favoritesService = FavoritesService();

  List<Restaurant> _favoriteRestaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final allRestaurants = await _restaurantService.getRestaurants();
    final favoriteIds = await _favoritesService.getFavorites();

    setState(() {
      _favoriteRestaurants = allRestaurants.where((r) => favoriteIds.contains(r.id.toString())).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        title: const Text('My Favorites', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA8E6CF)))
          : _favoriteRestaurants.isEmpty
              ? const Center(
                  child: Text(
                    "You haven't added any favorites yet.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteRestaurants.length,
                  itemBuilder: (context, index) {
                    final r = _favoriteRestaurants[index];
                    return _buildRestaurantCard(context, r);
                  },
                ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant r) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(restaurant: r),
          ),
        );
        // Reload favorites when returning from detail screen
        _loadFavorites();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFA8E6CF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        r.rating,
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.cuisine.isNotEmpty ? r.cuisine : r.type,
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          r.area,
                          style: const TextStyle(color: Colors.black87, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await _favoritesService.removeFavorite(r.id);
                _loadFavorites();
              },
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
