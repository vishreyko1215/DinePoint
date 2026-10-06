import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  var factory = databaseFactoryFfi;
  var dbPath = await factory.getDatabasesPath();
  var path = dbPath + '\\dinepoint.db';
  print('=================================');
  print('Database Path: ' + path);
  print('=================================');
  
  if (await File(path).exists()) {
    var db = await factory.openDatabase(path);
    
    // Print SQLite version and PRAGMA table_info
    print('\n--- Table Info for users ---');
    try {
      var tableInfo = await db.rawQuery('PRAGMA table_info(users)');
      for (var col in tableInfo) {
        print('Column: ${col["name"]} | Type: ${col["type"]} | PK: ${col["pk"]} | NotNull: ${col["notnull"]}');
      }
    } catch (e) {
      print('Error querying table info: $e');
    }
    
    print('\n--- Registered Users ---');
    var users = await db.query('users');
    if (users.isEmpty) {
      print('The users table is currently empty.');
    } else {
      for (var user in users) {
        print('- User: ' + user["name"].toString() + ' | Phone: ' + user["phone"].toString() + ' | Created: ' + user["created_at"].toString());
      }
    }
    await db.close();
  } else {
    print('Database not found yet. Make sure you registered someone in the app first!');
  }
}
