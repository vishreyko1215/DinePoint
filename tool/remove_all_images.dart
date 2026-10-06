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
    // Remove the image URLs to force the initial gradient fallback on all cards
    restaurant['imageUrl'] = '';
    restaurant['menuImageUrl'] = '';
  }

  // Write back to the file
  file.writeAsStringSync(jsonEncode(data));
  print('Removed images from all ${data.length} restaurants!');
}
