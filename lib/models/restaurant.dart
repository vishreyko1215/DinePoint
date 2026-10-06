import 'dart:convert';

class Restaurant {
  final String id;
  final String name;
  final String rating;
  final String area;
  final String type;
  final double lat;
  final double lon;
  final String address;
  final String imageUrl;
  final String phone;
  final String website;
  
  // New fields for Figma detail screen
  final String cuisine;
  final String priceRange;
  final String about;
  final List<String> reviews;
  final String menuImageUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.area,
    required this.type,
    required this.lat,
    required this.lon,
    required this.address,
    required this.imageUrl,
    required this.phone,
    required this.website,
    this.cuisine = '',
    this.priceRange = '',
    this.about = '',
    this.reviews = const [],
    this.menuImageUrl = '',
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    String nameVal = json['name'] ?? '';
    // Remove "mock" / "Mock" case-insensitively
    nameVal = nameVal.replaceAll(RegExp(r'\bmock\b', caseSensitive: false), '').trim();
    // Clean up any double spaces
    nameVal = nameVal.replaceAll(RegExp(r'\s+'), ' ');
    // If it starts with "in " after removing mock (e.g. "Mock in BTM Layout")
    if (nameVal.toLowerCase().startsWith('in ')) {
      nameVal = nameVal.substring(3).trim();
    }
    // Capitalize the first letter if needed
    if (nameVal.isNotEmpty) {
      nameVal = nameVal[0].toUpperCase() + nameVal.substring(1);
    }

    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: nameVal,
      rating: json['rating'] ?? '0.0',
      area: json['area'] ?? '',
      type: json['type'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      cuisine: json['cuisine'] ?? '',
      priceRange: json['priceRange'] ?? '',
      about: json['about'] ?? '',
      reviews: _parseReviews(json['reviews']),
      menuImageUrl: json['menuImageUrl'] ?? '',
    );
  }

  static List<String> _parseReviews(dynamic reviewsData) {
    if (reviewsData == null) return [];
    if (reviewsData is String) {
      try {
        final decoded = jsonDecode(reviewsData);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        return [];
      }
    }
    if (reviewsData is List) {
      return reviewsData.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'area': area,
      'type': type,
      'lat': lat,
      'lon': lon,
      'address': address,
      'imageUrl': imageUrl,
      'phone': phone,
      'website': website,
      'cuisine': cuisine,
      'priceRange': priceRange,
      'about': about,
      'reviews': reviews,
      'menuImageUrl': menuImageUrl,
    };
  }

  String get displayImageUrl {
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return imageUrl;
    }
    
    // Fallback images based on cuisine type
    final cleanCuisine = cuisine.trim().toLowerCase();
    if (cleanCuisine.contains('italian') || cleanCuisine.contains('pizza') || cleanCuisine.contains('pasta')) {
      return 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80';
    } else if (cleanCuisine.contains('chinese') || cleanCuisine.contains('noodle') || cleanCuisine.contains('asian')) {
      return 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=600&q=80';
    } else if (cleanCuisine.contains('indian') || cleanCuisine.contains('biryani') || cleanCuisine.contains('curry')) {
      return 'https://images.unsplash.com/photo-1585938338392-50a59970d8ee?auto=format&fit=crop&w=600&q=80';
    } else if (cleanCuisine.contains('mexican') || cleanCuisine.contains('taco') || cleanCuisine.contains('burrito')) {
      return 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=600&q=80';
    } else if (cleanCuisine.contains('american') || cleanCuisine.contains('burger') || cleanCuisine.contains('fast food')) {
      return 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80';
    } else if (cleanCuisine.contains('dessert') || cleanCuisine.contains('cake') || cleanCuisine.contains('sweet') || cleanCuisine.contains('bakery')) {
      return 'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=600&q=80';
    }
    
    // Generic high-quality restaurant aesthetic fallback image
    return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80';
  }
}
