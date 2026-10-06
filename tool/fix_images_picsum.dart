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
    // Generate a reliable picsum image based on the restaurant's ID
    restaurant['imageUrl'] = 'https://picsum.photos/seed/${restaurant['id']}/600/400';
  }

  // Write back to the file
  file.writeAsStringSync(jsonEncode(data));
  print('Updated restaurants.json with reliable picsum images!');
}
