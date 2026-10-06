import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/data/restaurants.json');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }

  final content = file.readAsStringSync();
  final List<dynamic> data = jsonDecode(content);

  for (var restaurant in data) {
    // Generate a reliable loremflickr image based on the restaurant's ID to keep it consistent
    restaurant['imageUrl'] = 'https://loremflickr.com/600/400/food,restaurant?lock=${restaurant['id']}';
  }

  // Write back to the file
  file.writeAsStringSync(jsonEncode(data));
  print('Updated restaurants.json with reliable loremflickr images!');
}
