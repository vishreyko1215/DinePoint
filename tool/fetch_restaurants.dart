import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Coordinate representation of a Bangalore neighborhood
class Neighborhood {
  final String name;
  final double lat;
  final double lon;

  const Neighborhood(this.name, this.lat, this.lon);
}

// Major Bangalore neighborhoods with coordinates to calculate proximity
const List<Neighborhood> neighborhoods = [
  Neighborhood("Koramangala", 12.9352, 77.6244),
  Neighborhood("Indiranagar", 12.9719, 77.6412),
  Neighborhood("Jayanagar", 12.9308, 77.5830),
  Neighborhood("Whitefield", 12.9698, 77.7500),
  Neighborhood("HSR Layout", 12.9101, 77.6450),
  Neighborhood("BTM Layout", 12.9166, 77.6101),
  Neighborhood("MG Road", 12.9738, 77.6119),
  Neighborhood("Malleshwaram", 12.9961, 77.5702),
  Neighborhood("Yelahanka", 13.1007, 77.5963),
  Neighborhood("Hebbal", 13.0358, 77.5970),
  Neighborhood("Rajajinagar", 12.9897, 77.5552),
  Neighborhood("Electronic City", 12.8452, 77.6630),
];

// Map of Unsplash photo URLs for each category to ensure high aesthetic appeal
const Map<String, List<String>> categoryImages = {
  "Indian": [
    "https://images.unsplash.com/photo-1585938338392-50a59970d8ee?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&auto=format&fit=crop&q=80"
  ],
  "Chinese": [
    "https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1552611052-33e04de081de?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&auto=format&fit=crop&q=80"
  ],
  "Italian": [
    "https://images.unsplash.com/photo-1534080391025-a87b995d410d?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600&auto=format&fit=crop&q=80"
  ],
  "American": [
    "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1460306855393-0410f61241c7?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1550547660-d9450f859349?w=600&auto=format&fit=crop&q=80"
  ],
  "Cafe": [
    "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=600&auto=format&fit=crop&q=80"
  ],
  "Other": [
    "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=600&auto=format&fit=crop&q=80",
    "https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=600&auto=format&fit=crop&q=80"
  ]
};

void main() async {
  print("🚀 Initializing DinePoint Bangalore Restaurant Data Scraper (via Nominatim)...");
  
  final client = HttpClient();
  final List<Map<String, dynamic>> structuredRestaurants = [];
  final Set<String> uniqueIds = {};

  final searchQueries = [
    {"q": "restaurants in bangalore", "defaultType": "Indian"},
    {"q": "cafes in bangalore", "defaultType": "Cafe"},
    {"q": "pizza in bangalore", "defaultType": "Italian"},
    {"q": "burgers in bangalore", "defaultType": "American"},
    {"q": "bakeries in bangalore", "defaultType": "Desserts"},
  ];

  try {
    for (var queryConfig in searchQueries) {
      final queryText = queryConfig["q"]!;
      final defaultType = queryConfig["defaultType"]!;
      
      print("📡 Fetching '$queryText' from Nominatim Search API...");
      
      // Nominatim requires a proper User-Agent to avoid blocking
      final uri = Uri.parse("https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(queryText)}&format=json&limit=80");
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, "DinePointLocator/1.0 (contact: support@dinepoint.com)");
      
      final response = await request.close();
      if (response.statusCode != 200) {
        print("⚠️ Failed to fetch '$queryText': HTTP ${response.statusCode}");
        continue;
      }
      
      final responseBody = await response.transform(utf8.decoder).join();
      final List<dynamic> results = jsonDecode(responseBody);
      
      print("📥 Found ${results.length} results for '$queryText'. Processing...");
      
      for (var item in results) {
        final String placeId = item['place_id']?.toString() ?? "";
        if (placeId.isEmpty || uniqueIds.contains(placeId)) continue;
        
        final String displayName = item['display_name'] ?? "";
        if (displayName.isEmpty) continue;
        
        // Extract restaurant name (always the first part of display_name)
        final parts = displayName.split(',');
        final String name = parts[0].trim();
        if (name.length < 2) continue; // Skip single characters or noise
        
        final double lat = double.parse(item['lat']);
        final double lon = double.parse(item['lon']);
        
        // Calculate closest neighborhood area
        String area = "Bangalore";
        double minDistance = double.infinity;
        for (var neighborhood in neighborhoods) {
          final distance = sqrt(pow(lat - neighborhood.lat, 2) + pow(lon - neighborhood.lon, 2));
          if (distance < minDistance) {
            minDistance = distance;
            area = neighborhood.name;
          }
        }
        
        // Determine type/cuisine based on item text or query type
        String type = defaultType;
        final lowerName = name.toLowerCase();
        
        if (lowerName.contains("chinese") || lowerName.contains("wok") || lowerName.contains("momo") || lowerName.contains("dragon") || lowerName.contains("noodles")) {
          type = "Chinese";
        } else if (lowerName.contains("pizza") || lowerName.contains("pasta") || lowerName.contains("italian") || lowerName.contains("pizzeria")) {
          type = "Italian";
        } else if (lowerName.contains("burger") || lowerName.contains("subway") || lowerName.contains("sandwich") || lowerName.contains("diner") || lowerName.contains("kfc") || lowerName.contains("mcdonald")) {
          type = "American";
        } else if (lowerName.contains("cafe") || lowerName.contains("coffee") || lowerName.contains("tea") || lowerName.contains("ccd") || lowerName.contains("starbucks")) {
          type = "Cafe";
        } else if (lowerName.contains("bake") || lowerName.contains("sweet") || lowerName.contains("cake") || lowerName.contains("dessert") || lowerName.contains("ice cream") || lowerName.contains("pastry") || lowerName.contains("waffle")) {
          type = "Desserts";
        } else if (lowerName.contains("biryani") || lowerName.contains("sagar") || lowerName.contains("dhaba") || lowerName.contains("hotel") || lowerName.contains("grand") || lowerName.contains("curry") || lowerName.contains("south indian") || lowerName.contains("north indian")) {
          type = "Indian";
        }
        
        // Generate stable rating between 3.8 and 4.9 based on placeId hash
        final idHash = placeId.hashCode;
        final double rating = 3.8 + ((idHash.abs() % 12) / 10.0);
        
        // Select standard image URL
        final images = categoryImages[type] ?? categoryImages["Other"]!;
        final imageUrl = images[idHash.abs() % images.length];
        
        // Form a cleaner address (display_name minus the name)
        String address = parts.skip(1).take(3).join(',').trim();
        if (address.isEmpty) {
          address = "Near $area, Bangalore";
        }
        
        // Phone and website placeholders (Nominatim main results don't include them, but we provide mock/contact info for details screen)
        final phone = "+91 80 ${4000 + (idHash.abs() % 6000)} ${100 + (idHash.abs() % 900)}";
        final website = "https://www.${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}.in";
        
        uniqueIds.add(placeId);
        structuredRestaurants.add({
          "id": placeId,
          "name": name,
          "rating": rating.toStringAsFixed(1),
          "area": area,
          "type": type,
          "lat": lat,
          "lon": lon,
          "address": address,
          "imageUrl": imageUrl,
          "phone": phone,
          "website": website,
        });
      }
      
      // Respect Nominatim's rate limit of 1 request per second
      await Future.delayed(const Duration(seconds: 1));
    }

    print("📝 Saving ${structuredRestaurants.length} unique, processed restaurants to assets database...");
    
    final file = File("assets/data/restaurants.json");
    await file.parent.create(recursive: true);
    
    final jsonEncoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(jsonEncoder.convert(structuredRestaurants));
    
    print("✨ Successfully ingested data! Saved to 'assets/data/restaurants.json'");
  } catch (e) {
    print("❌ Error fetching or parsing data from Nominatim: $e");
  } finally {
    client.close();
  }
}
