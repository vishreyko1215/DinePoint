import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';
import '../services/favorites_service.dart';


class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  Future<void> _launchNavigation() async {
    final query = Uri.encodeComponent('${widget.restaurant.name} ${widget.restaurant.area}');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch maps: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.restaurant.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoritesService.removeFavorite(widget.restaurant.id);
    } else {
      await _favoritesService.addFavorite(widget.restaurant.id);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? "Added to Favorites" : "Removed from Favorites"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery (Mock horizontal list)
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildGalleryImage(widget.restaurant.displayImageUrl),
                  const SizedBox(width: 8),
                  _buildGalleryImage('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&auto=format&fit=crop&q=80'),
                  const SizedBox(width: 8),
                  _buildGalleryImage('https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=80'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Info Card (Teal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFA8E6CF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.restaurant.rating,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.restaurant.cuisine,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.restaurant.area,
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.restaurant.priceRange,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "About:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.restaurant.about,
                    style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                  ),

                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Action Buttons
             Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _launchNavigation,
                    icon: const Icon(Icons.navigation, color: Colors.white, size: 16),
                    label: const Text("Navigate", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleFavorite,
                    icon: Icon(_isFavorite ? Icons.star : Icons.star_border, color: Colors.white, size: 16),
                    label: Text(_isFavorite ? "Favorited" : "Favorite", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFavorite ? Colors.grey.shade600 : const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            
            if (widget.restaurant.phone.isNotEmpty && widget.restaurant.phone != 'Not available') ...[
              const Text("Contact Information", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Color(0xFFA8E6CF), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.restaurant.phone, 
                      style: const TextStyle(color: Colors.white70, fontSize: 15)
                    ),
                  ],
                ),
              ),
            ], 
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 180,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 180,
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD5E5D5), Color(0xFFC8DCD0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.restaurant.name.isNotEmpty ? widget.restaurant.name.substring(0, 1).toUpperCase() : 'R',
            style: const TextStyle(color: Colors.black54, fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
