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
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1414235077428-338988a2e8c0?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1466978913421-bac2e5e42729?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1502301103665-0b95cc738daf?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1525648199074-cee30ba79a4a?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1481833761820-0509d3217039?w=600&auto=format&fit=crop&q=80', 
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80', 
  ];

  for (var restaurant in data) {
    // 1. Force Image URL if it's invalid or missing
    if (restaurant['imageUrl'] == null || restaurant['imageUrl'].toString().trim().isEmpty || !restaurant['imageUrl'].toString().startsWith('http')) {
      restaurant['imageUrl'] = imageUrls[random.nextInt(imageUrls.length)];
    }

    // 2. Generate Random Phone Number
    if (restaurant['phone'] == null || restaurant['phone'].toString().trim().isEmpty) {
      restaurant['phone'] = '+91 9${random.nextInt(90000000) + 10000000}';
    }

    // 3. Generate Random Website
    if (restaurant['website'] == null || restaurant['website'].toString().trim().isEmpty) {
      String nameForWeb = restaurant['name'].toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      restaurant['website'] = 'www.$nameForWeb.com';
    }

    // 4. Generate small description based on restaurant
    if (restaurant['about'] == null || restaurant['about'].toString().trim().isEmpty) {
      String name = restaurant['name'];
      String type = restaurant['type'] ?? 'dining';
      String area = restaurant['area'] ?? 'the city';
      restaurant['about'] = 'Welcome to $name, a wonderful $type destination located in the heart of $area. Enjoy a delightful culinary experience with our carefully crafted dishes and warm ambiance. Perfect for family gatherings, casual outings, and special occasions.';
    }
  }

  // Write back to the file
  file.writeAsStringSync(jsonEncode(data));
  print('Updated restaurants.json successfully with phone, website, and about sections!');
}
