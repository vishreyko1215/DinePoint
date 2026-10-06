import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final file = File('assets/data/restaurants.json');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }

  final content = file.readAsStringSync();
  final List<dynamic> data = jsonDecode(content);

  final random = Random();

  final List<String> imageUrls = [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=80', // Restaurant interior
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&auto=format&fit=crop&q=80', // Restaurant food
    'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600&auto=format&fit=crop&q=80', // Restaurant
    'https://images.unsplash.com/photo-1414235077428-338988a2e8c0?w=600&auto=format&fit=crop&q=80', // Fine dining
    'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&auto=format&fit=crop&q=80', // Restaurant tables
    'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=600&auto=format&fit=crop&q=80', // Outdoor seating
    'https://images.unsplash.com/photo-1466978913421-bac2e5e42729?w=600&auto=format&fit=crop&q=80', // Food and wine
    'https://images.unsplash.com/photo-1502301103665-0b95cc738daf?w=600&auto=format&fit=crop&q=80', // Casual dining
    'https://images.unsplash.com/photo-1525648199074-cee30ba79a4a?w=600&auto=format&fit=crop&q=80', // Burger
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&auto=format&fit=crop&q=80', // Pizza
    'https://images.unsplash.com/photo-1481833761820-0509d3217039?w=600&auto=format&fit=crop&q=80', // Tacos
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80', // Salad
  ];

  for (var restaurant in data) {
    if (restaurant['rating'] == '0.0' || restaurant['rating'] == '' || restaurant['rating'] == null) {
      // Generate a random rating between 3.5 and 5.0
      double r = 3.5 + random.nextDouble() * 1.5;
      restaurant['rating'] = r.toStringAsFixed(1);
    }
    
    if (restaurant['imageUrl'] == '' || restaurant['imageUrl'] == null) {
      // Pick a random image URL
      restaurant['imageUrl'] = imageUrls[random.nextInt(imageUrls.length)];
    }
  }

  // Write back to the file
  file.writeAsStringSync(jsonEncode(data));
  print('Updated restaurants.json successfully!');
}
