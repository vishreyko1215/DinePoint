import 'dart:convert';
import 'dart:io';
import 'dart:math';

class Neighborhood {
  final String name;
  final double lat;
  final double lon;

  const Neighborhood(this.name, this.lat, this.lon);
}

const List<Neighborhood> neighborhoods = [
  Neighborhood("Indiranagar", 12.9719, 77.6412),
  Neighborhood("Whitefield", 12.9698, 77.7500),
  Neighborhood("Koramangala", 12.9352, 77.6244),
  Neighborhood("HSR Layout", 12.9101, 77.6450),
  Neighborhood("Jayanagar", 12.9308, 77.5830),
  Neighborhood("Church Street", 12.9747, 77.6039),
];

void main() async {
  print("📡 Querying Overpass API for all food/drink locations in Bangalore...");
  
  final client = HttpClient();
  
  final overpassQuery = '''
[out:json][timeout:90];
(
  node["amenity"="restaurant"](12.88,77.52,13.05,77.78);
  node["amenity"="cafe"](12.88,77.52,13.05,77.78);
  node["amenity"="fast_food"](12.88,77.52,13.05,77.78);
  node["amenity"="pub"](12.88,77.52,13.05,77.78);
  node["amenity"="bar"](12.88,77.52,13.05,77.78);
  node["amenity"="ice_cream"](12.88,77.52,13.05,77.78);
  
  way["amenity"="restaurant"](12.88,77.52,13.05,77.78);
  way["amenity"="cafe"](12.88,77.52,13.05,77.78);
  way["amenity"="fast_food"](12.88,77.52,13.05,77.78);
  way["amenity"="pub"](12.88,77.52,13.05,77.78);
);
out center;
''';

  final List<Map<String, dynamic>> realRestaurants = [];
  final Set<String> uniqueKeys = {};

  final prices = ['Under ₹300', '₹300 - ₹600', '₹600+'];
  final ambiences = ['Casual', 'Fancy', 'Café', 'Family'];
  final cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican', 'American', 'Dessert'];

  final endpoints = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://overpass.openstreetmap.ru/api/interpreter"
  ];

  Map<String, dynamic>? oData;

  for (var endpoint in endpoints) {
    try {
      print("📡 Trying endpoint: $endpoint");
      final uri = Uri.parse("$endpoint?data=${Uri.encodeQueryComponent(overpassQuery)}");
      final request = await client.getUrl(uri);
      
      request.headers.set(HttpHeaders.userAgentHeader, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
      request.headers.set(HttpHeaders.acceptHeader, "application/json, text/plain, */*");
      request.headers.set(HttpHeaders.acceptLanguageHeader, "en-US,en;q=0.9");
      
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        oData = jsonDecode(responseBody);
        print("✅ Success using: $endpoint");
        break;
      } else {
        print("❌ Error from $endpoint: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Connection failed for $endpoint: $e");
    }
  }

  if (oData == null) {
    print("❌ All Overpass endpoints failed.");
    client.close();
    return;
  }

  final List<dynamic> elements = oData['elements'] ?? [];
  print("📥 Received ${elements.length} raw elements from Overpass.");

  for (var element in elements) {
    final tags = element['tags'];
    if (tags == null) continue;

    final String name = tags['name'] ?? "";
    if (name.isEmpty || name.length < 2) continue;
    if (name.startsWith('The Mock ')) continue;

    double? lat;
    double? lon;
    if (element['type'] == 'node') {
      lat = (element['lat'] as num?)?.toDouble();
      lon = (element['lon'] as num?)?.toDouble();
    } else if (element['type'] == 'way' && element['center'] != null) {
      lat = (element['center']['lat'] as num?)?.toDouble();
      lon = (element['center']['lon'] as num?)?.toDouble();
    }

    if (lat == null || lon == null) continue;

    String closestArea = "Indiranagar";
    double minDistance = double.infinity;
    for (var neighborhood in neighborhoods) {
      final distance = sqrt(pow(lat - neighborhood.lat, 2) + pow(lon - neighborhood.lon, 2));
      if (distance < minDistance) {
        minDistance = distance;
        closestArea = neighborhood.name;
      }
    }

    // Keep it within ~2.5 km (around 0.025 degrees)
    if (minDistance > 0.025) {
      continue;
    }

    final uniqueKey = "${name.toLowerCase()}_${closestArea.toLowerCase()}";
    if (uniqueKeys.contains(uniqueKey)) continue;
    uniqueKeys.add(uniqueKey);

    String cuisineVal = tags['cuisine'] ?? "";
    String determinedCuisine = "Indian";

    final lowerCuisine = cuisineVal.toLowerCase();
    final lowerName = name.toLowerCase();

    if (lowerCuisine.contains("italian") || lowerCuisine.contains("pizza") || lowerCuisine.contains("pasta") ||
        lowerName.contains("pizza") || lowerName.contains("pasta") || lowerName.contains("pizzeria") || lowerName.contains("italian")) {
      determinedCuisine = "Italian";
    } else if (lowerCuisine.contains("chinese") || lowerCuisine.contains("asian") || lowerCuisine.contains("noodle") ||
        lowerName.contains("chinese") || lowerName.contains("momo") || lowerName.contains("dim sum") || lowerName.contains("wok") || lowerName.contains("dragon")) {
      determinedCuisine = "Chinese";
    } else if (lowerCuisine.contains("mexican") || lowerCuisine.contains("tex-mex") ||
        lowerName.contains("mexican") || lowerName.contains("taco") || lowerName.contains("burrito") || lowerName.contains("quesadilla") || lowerName.contains("nacho")) {
      determinedCuisine = "Mexican";
    } else if (lowerCuisine.contains("burger") || lowerCuisine.contains("american") || lowerCuisine.contains("sandwich") ||
        lowerName.contains("burger") || lowerName.contains("subway") || lowerName.contains("sandwich") || lowerName.contains("american") || lowerName.contains("kfc") || lowerName.contains("mcdonald")) {
      determinedCuisine = "American";
    } else if (lowerCuisine.contains("bakery") || lowerCuisine.contains("cake") || lowerCuisine.contains("dessert") || lowerCuisine.contains("ice_cream") || lowerCuisine.contains("cafe") || lowerCuisine.contains("coffee") ||
        lowerName.contains("cafe") || lowerName.contains("coffee") || lowerName.contains("starbucks") || lowerName.contains("tea") || lowerName.contains("bake") || lowerName.contains("cake") || lowerName.contains("dessert") || lowerName.contains("sweet") || lowerName.contains("pastry") || lowerName.contains("ice cream")) {
      determinedCuisine = "Dessert";
    } else {
      determinedCuisine = "Indian";
    }

    String priceRange = '₹300 - ₹600';
    String ambience = 'Casual';

    final amenity = tags['amenity'];
    if (amenity == 'cafe' || determinedCuisine == 'Dessert') {
      ambience = 'Café';
      priceRange = 'Under ₹300';
    } else if (amenity == 'pub' || amenity == 'bar') {
      ambience = 'Fancy';
      priceRange = '₹600+';
    }

    if (lowerName.contains("dhaba") || lowerName.contains("sagar") || lowerName.contains("darshini") || lowerName.contains("fast food") || lowerName.contains("roll") || lowerName.contains("tapri") || lowerName.contains("mess") || lowerName.contains("tea joint")) {
      priceRange = 'Under ₹300';
      ambience = 'Casual';
    }
    
    if (lowerName.contains("fine") || lowerName.contains("gourmet") || lowerName.contains("skybar") || lowerName.contains("roof") || lowerName.contains("lounge") || lowerName.contains("brewery") || lowerName.contains("bistro") || lowerName.contains("kitchen & bar") || lowerName.contains("social") || lowerName.contains("microbrewery")) {
      priceRange = '₹600+';
      ambience = 'Fancy';
    }

    if (lowerName.contains("family") || lowerName.contains("grand") || lowerName.contains("palace") || lowerName.contains("court") || lowerName.contains("kitchen") || lowerName.contains("house") || lowerName.contains("hotel")) {
      ambience = 'Family';
    }

    final hash = name.hashCode.abs();
    if (priceRange == '₹300 - ₹600') {
      priceRange = prices[hash % prices.length];
    }
    if (ambience == 'Casual' && determinedCuisine != 'Dessert') {
      ambience = ambiences[hash % ambiences.length];
    }

    final double rating = 3.5 + ((hash % 15) / 10.0);
    final phone = tags['phone'] ?? "+91 80 ${4000 + (hash % 6000)} ${100 + (hash % 900)}";
    final website = tags['website'] ?? "https://www.dinepoint.com";
    
    String address = tags['addr:street'] ?? "";
    if (address.isEmpty) {
      address = tags['addr:housenumber'] ?? "";
      if (address.isNotEmpty) address += ", ";
      address += closestArea;
    } else {
      address += ", $closestArea";
    }

    realRestaurants.add({
      "id": element['id']?.toString() ?? "osm_${hash}",
      "name": name,
      "rating": rating.toStringAsFixed(1),
      "area": closestArea,
      "type": ambience,
      "lat": lat,
      "lon": lon,
      "address": address,
      "imageUrl": "",
      "phone": phone,
      "website": website,
      "cuisine": determinedCuisine,
      "priceRange": priceRange,
      "about": "Welcome to $name. Experience the best $determinedCuisine food in $closestArea with a $ambience atmosphere.",
      "reviews": [],
      "menuImageUrl": ""
    });
  }

  // Save JSON
  final file = File("assets/data/restaurants.json");
  final jsonEncoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(jsonEncoder.convert(realRestaurants));
  print("✨ Successfully saved ${realRestaurants.length} REAL restaurants to 'assets/data/restaurants.json'.");

  // Check missing combos
  final missingCombosList = <String>[];
  final areasList = ['Indiranagar', 'Whitefield', 'Koramangala', 'HSR Layout', 'Jayanagar', 'Church Street'];

  for (var c in cuisines) {
    for (var p in prices) {
      for (var am in ambiences) {
        for (var ar in areasList) {
          final exists = realRestaurants.any((r) =>
            r['cuisine'] == c &&
            r['priceRange'] == p &&
            r['type'] == am &&
            r['area'] == ar
          );

          if (!exists) {
            missingCombosList.add("$c | $p | $am | $ar");
          }
        }
      }
    }
  }

  print("⚠️ Missing combinations: ${missingCombosList.length} out of 432.");
  final reportFile = File("tool/missing_combos_report.txt");
  reportFile.writeAsStringSync(missingCombosList.join("\n"));
  print("📝 Report saved to 'tool/missing_combos_report.txt'.");

  client.close();
}
