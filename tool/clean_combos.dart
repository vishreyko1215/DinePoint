import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final file = File('assets/data/restaurants.json');
  if (!file.existsSync()) { print('File not found'); return; }

  final List<dynamic> data = jsonDecode(file.readAsStringSync());

  // Step 1: Keep ONLY real restaurants (remove every fake)
  final real = data.where((r) => !(r['name'] as String).startsWith('The Mock ')).toList();
  print('Real restaurants kept: ${real.length}');

  final cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican', 'American', 'Dessert'];
  final prices = ['Under ₹300', '₹300 - ₹600', '₹600+'];
  final ambiences = ['Casual', 'Fancy', 'Café', 'Family'];
  final areas = ['Indiranagar', 'Whitefield', 'Koramangala', 'HSR Layout', 'Jayanagar', 'Church Street'];

  final random = Random();
  final List<dynamic> result = List.from(real);
  int added = 0;

  // Step 2: For each combo with NO real restaurant, add exactly 1 fake
  for (var c in cuisines) {
    for (var p in prices) {
      for (var am in ambiences) {
        for (var ar in areas) {
          final realExists = real.any((r) =>
            r['cuisine'] == c &&
            r['priceRange'] == p &&
            r['type'] == am &&
            r['area'] == ar
          );

          if (!realExists) {
            final id = 'fake_${c}_${p}_${am}_${ar}'.replaceAll(' ', '_').replaceAll('₹', 'rs');
            double baseLat = 12.9716, baseLon = 77.5946;
            if (ar == 'Indiranagar')  { baseLat = 12.9784; baseLon = 77.6408; }
            if (ar == 'Whitefield')   { baseLat = 12.9698; baseLon = 77.7499; }
            if (ar == 'Koramangala')  { baseLat = 12.9352; baseLon = 77.6245; }
            if (ar == 'HSR Layout')   { baseLat = 12.9121; baseLon = 77.6446; }
            if (ar == 'Jayanagar')    { baseLat = 12.9299; baseLon = 77.5824; }
            if (ar == 'Church Street'){ baseLat = 12.9747; baseLon = 77.6039; }

            result.add({
              "id": id,
              "name": "The Mock ${c} ${am}",
              "rating": (3.5 + random.nextDouble() * 1.5).toStringAsFixed(1),
              "area": ar,
              "type": am,
              "lat": baseLat + (random.nextDouble() - 0.5) * 0.02,
              "lon": baseLon + (random.nextDouble() - 0.5) * 0.02,
              "address": "$ar, Bangalore",
              "imageUrl": "",
              "phone": "+91 9${random.nextInt(90000000) + 10000000}",
              "website": "",
              "cuisine": c,
              "priceRange": p,
              "about": "A $am $c restaurant in $ar.",
              "reviews": [],
              "menuImageUrl": ""
            });
            added++;
          }
        }
      }
    }
  }

  file.writeAsStringSync(jsonEncode(result));
  print('Done! ${result.length} total (${real.length} real + $added fakes for missing combos)');
}
