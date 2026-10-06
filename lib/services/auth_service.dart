import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class AuthService {
  static const String _keyCurrentUser = 'current_user';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Check if a user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyCurrentUser);
  }

  // Get current user details
  Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    final Map<String, dynamic> decoded = jsonDecode(userJson);
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  // Check if a phone number is registered
  Future<bool> isUserRegistered(String phone) async {
    final user = await _dbHelper.getUser(phone);
    return user != null;
  }

  // Log in an existing user
  Future<bool> login(String phone) async {
    final user = await _dbHelper.getUser(phone);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final userMap = {'name': user['name'], 'phone': phone};
      await prefs.setString(_keyCurrentUser, jsonEncode(userMap));
      return true;
    }
    return false;
  }

  // Register and log in a new user
  Future<void> register(String name, String phone) async {
    // Save to permanent SQLite database
    await _dbHelper.createUser(phone, name);

    // Log the user in to the active session
    final prefs = await SharedPreferences.getInstance();
    final userMap = {'name': name, 'phone': phone};
    await prefs.setString(_keyCurrentUser, jsonEncode(userMap));
  }

  // Log out current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
  }
}
