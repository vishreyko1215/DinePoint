import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dinepoint.db');

    return await openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createRestaurantsTable(db);
          await _seedRestaurants(db);
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            phone TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await _createRestaurantsTable(db);
        await _seedRestaurants(db);
      },
    );
  }

  Future<void> _createRestaurantsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS restaurants (
        id TEXT PRIMARY KEY,
        name TEXT,
        rating TEXT,
        area TEXT,
        type TEXT,
        lat REAL,
        lon REAL,
        address TEXT,
        imageUrl TEXT,
        phone TEXT,
        website TEXT,
        cuisine TEXT,
        priceRange TEXT,
        about TEXT,
        reviews TEXT,
        menuImageUrl TEXT
      )
    ''');
  }

  Future<void> _seedRestaurants(Database db) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/restaurants.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      final batch = db.batch();
      for (var item in jsonList) {
        batch.insert('restaurants', {
          'id': item['id']?.toString() ?? '',
          'name': item['name'] ?? '',
          'rating': item['rating']?.toString() ?? '0.0',
          'area': item['area'] ?? '',
          'type': item['type'] ?? '',
          'lat': (item['lat'] as num?)?.toDouble() ?? 0.0,
          'lon': (item['lon'] as num?)?.toDouble() ?? 0.0,
          'address': item['address'] ?? '',
          'imageUrl': item['imageUrl'] ?? '',
          'phone': item['phone'] ?? '',
          'website': item['website'] ?? '',
          'cuisine': item['cuisine'] ?? '',
          'priceRange': item['priceRange'] ?? '',
          'about': item['about'] ?? '',
          'reviews': jsonEncode(item['reviews'] ?? []),
          'menuImageUrl': item['menuImageUrl'] ?? '',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
      print("✅ Successfully seeded SQLite with restaurants!");
    } catch (e) {
      print("❌ Error seeding restaurants: \$e");
    }
  }

  Future<void> createUser(String phone, String name) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'phone': phone,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Map<String, dynamic>?> getUser(String phone) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllRestaurants() async {
    final db = await database;
    return await db.query('restaurants');
  }
}
