import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final jsonFile = File('assets/data/restaurants.json');
  if (!jsonFile.existsSync()) { print('restaurants.json not found'); return; }

  final List<dynamic> data = jsonDecode(jsonFile.readAsStringSync());

  // Remove any previously added mocks to start fresh
  data.removeWhere((r) => (r['name'] as String).startsWith('Mock '));
  print('Real restaurants: ${data.length}');

  final cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican', 'American', 'Dessert'];
  final areas = [
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
    'Electronic City'
  ];

  final areaCoords = {
    'Indiranagar':    [12.9784, 77.6408],
    'Whitefield':     [12.9698, 77.7499],
    'Koramangala':    [12.9352, 77.6245],
    'HSR Layout':     [12.9121, 77.6446],
    'Jayanagar':      [12.9299, 77.5824],
    'Church Street':  [12.9747, 77.6039],
    'BTM Layout':      [12.9166, 77.6101],
    'MG Road':         [12.9738, 77.6119],
    'Malleshwaram':    [12.9961, 77.5702],
    'Yelahanka':       [13.1007, 77.5963],
    'Hebbal':          [13.0358, 77.5970],
    'Rajajinagar':      [12.9897, 77.5552],
    'Electronic City': [12.8452, 77.6630],
  };

  final random = Random();
  int added = 0;

  for (var cuisine in cuisines) {
    for (var area in areas) {
      // Check if ANY real restaurant covers this cuisine+area combo
      final exists = data.any((r) => r['cuisine'] == cuisine && r['area'] == area);
      
      if (!exists) {
        final coords = areaCoords[area]!;
        final lat = coords[0] + (random.nextDouble() - 0.5) * 0.01;
        final lon = coords[1] + (random.nextDouble() - 0.5) * 0.01;
        final hash = ('$cuisine$area').hashCode.abs();

        data.add({
          "id": "mock_${cuisine}_${area}".toLowerCase().replaceAll(' ', '_'),
          "name": "Mock $cuisine in $area",
          "rating": (3.8 + random.nextDouble() * 1.0).toStringAsFixed(1),
          "area": area,
          "type": "Casual",
          "lat": lat,
          "lon": lon,
          "address": "$area, Bangalore",
          "imageUrl": "",
          "phone": "+91 9${random.nextInt(90000000) + 10000000}",
          "website": "https://www.dinepoint.com",
          "cuisine": cuisine,
          "priceRange": "₹300 - ₹600",
          "about": "A cozy $cuisine spot in $area.",
          "reviews": [],
          "menuImageUrl": ""
        });
        print('  Added mock: $cuisine | $area');
        added++;
      }
    }
  }

  const encoder = JsonEncoder.withIndent('  ');
  jsonFile.writeAsStringSync(encoder.convert(data));
  print('\nDone! Added $added mock restaurants (1 per missing cuisine+area combo).');
  print('Total restaurants: ${data.length}');
}
