import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final file = File('assets/data/restaurants.json');
  List<dynamic> data = [];
  if (file.existsSync()) {
    data = jsonDecode(file.readAsStringSync());
  }

  final cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican', 'American', 'Dessert'];
  final prices = ['Under ₹300', '₹300 - ₹600', '₹600+'];
  final ambiences = ['Casual', 'Fancy', 'Café', 'Family'];
  final areas = ['Indiranagar', 'Whitefield', 'Koramangala', 'HSR Layout', 'Jayanagar', 'Church Street'];

  final random = Random();
  int addedCount = 0;

  for (var c in cuisines) {
    for (var p in prices) {
      for (var am in ambiences) {
        for (var ar in areas) {
          // Check if this combo already exists in data
          bool exists = data.any((r) => 
            r['cuisine'] == c && 
            r['priceRange'] == p && 
            r['type'] == am && 
            r['area'] == ar
          );

          if (!exists) {
            final id = random.nextInt(1000000000).toString();
            
            double baseLat = 12.9716;
            double baseLon = 77.5946;
            
            if (ar == 'Indiranagar') { baseLat = 12.9784; baseLon = 77.6408; }
            if (ar == 'Whitefield') { baseLat = 12.9698; baseLon = 77.7499; }
            if (ar == 'Koramangala') { baseLat = 12.9352; baseLon = 77.6245; }
            if (ar == 'HSR Layout') { baseLat = 12.9121; baseLon = 77.6446; }
            if (ar == 'Jayanagar') { baseLat = 12.9299; baseLon = 77.5824; }
            if (ar == 'Church Street') { baseLat = 12.9747; baseLon = 77.6039; }

            double lat = baseLat + (random.nextDouble() - 0.5) * 0.02;
            double lon = baseLon + (random.nextDouble() - 0.5) * 0.02;

            data.add({
              "id": id,
              "name": "The Mock $c $am",
              "rating": (3.5 + random.nextDouble() * 1.5).toStringAsFixed(1),
              "area": ar,
              "type": am,
              "lat": lat,
              "lon": lon,
              "address": "Filler Street, $ar",
              "imageUrl": "", // Deliberately blank to trigger the fallback UI
              "phone": "+91 9${random.nextInt(90000000) + 10000000}",
              "website": "www.the${c.toLowerCase()}${am.toLowerCase()}.com",
              "cuisine": c,
              "priceRange": p,
              "about": "Welcome to The Mock $c $am. This is a filler restaurant.",
              "reviews": [],
              "menuImageUrl": ""
            });
            addedCount++;
          }
        }
      }
    }
  }

  file.writeAsStringSync(jsonEncode(data));
  print('Successfully filled $addedCount missing combinations!');
}
