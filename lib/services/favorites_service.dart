import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorites';

  // ------- Platform‑specific storage -------
  Future<List<String>> _loadFromFile() async {
    final file = await _localFile;
    if (!await file.exists()) return [];
    final String contents = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(contents);
    return jsonList.map((e) => e.toString()).toList();
  }

  Future<void> _saveToFile(List<String> ids) async {
    final file = await _localFile;
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final String jsonString = jsonEncode(ids);
    await file.writeAsString(jsonString);
    print('Favorites saved (file): $jsonString');
  }

  Future<List<String>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> _saveToPrefs(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
    print('Favorites saved (prefs): $ids');
  }

  // ------- Unified public API -------
  Future<List<String>> getFavorites() async {
    if (kIsWeb) {
      return await _loadFromPrefs();
    } else {
      return await _loadFromFile();
    }
  }

  Future<void> saveFavorites(List<String> favoriteIds) async {
    if (kIsWeb) {
      await _saveToPrefs(favoriteIds);
    } else {
      await _saveToFile(favoriteIds);
    }
  }

  Future<void> addFavorite(String restaurantId) async {
    print('Adding favorite: $restaurantId');
    final favorites = await getFavorites();
    if (!favorites.contains(restaurantId)) {
      favorites.add(restaurantId);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String restaurantId) async {
    print('Removing favorite: $restaurantId');
    final favorites = await getFavorites();
    if (favorites.contains(restaurantId)) {
      favorites.remove(restaurantId);
      await saveFavorites(favorites);
    }
  }

  Future<bool> isFavorite(String restaurantId) async {
    final favorites = await getFavorites();
    return favorites.contains(restaurantId);
  }

  // ------- Helper for non‑web file path -------
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/favorites.json');
  }
}
