import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('assets/data/restaurants.json');
  if (!await file.exists()) {
    print('File not found: ${file.path}');
    return;
  }

  final content = await file.readAsString();
  final List<dynamic> jsonList = jsonDecode(content);

  final enrichedList = jsonList.map((item) {
    final type = item['type'] as String? ?? 'Restaurant';
    final name = item['name'] as String? ?? 'Restaurant';
    
    // Assign reasonable cuisines based on type
    String cuisine = '$type • Casual Dining';
    if (type.toLowerCase().contains('cafe')) {
      cuisine = 'Cafe • Casual Dining';
    } else if (type.toLowerCase().contains('indian')) {
      cuisine = 'Indian • Family Dining';
    } else if (type.toLowerCase().contains('bar') || type.toLowerCase().contains('pub')) {
      cuisine = 'Bar • Nightlife';
    }

    // Assign price ranges
    final priceRange = '₹${(200 + (name.length * 10))}–₹${(500 + (name.length * 20))} per person';

    // Assign about text
    final about = '$name is a popular $type in Bangalore known for its relaxed atmosphere and great food. It is a popular spot for locals to hang out and enjoy quality time.';

    // Assign mock reviews
    final reviews = [
      'Great atmosphere and friendly vibe.',
      'Nice place to relax or study.',
      'Good food and quick service.',
    ];

    // Assign mock menu image (using unsplash)
    final menuImageUrl = 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=600&auto=format&fit=crop&q=80';

    item['cuisine'] = cuisine;
    item['priceRange'] = priceRange;
    item['about'] = about;
    item['reviews'] = reviews;
    item['menuImageUrl'] = menuImageUrl;

    return item;
  }).toList();

  final encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(enrichedList));

  print('Successfully enriched ${enrichedList.length} restaurants.');
}
