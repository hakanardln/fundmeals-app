import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

class StorageService {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    await _preferences.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _preferences.getString(AppConstants.tokenKey);
  }

  static Future<void> clearToken() async {
    await _preferences.remove(AppConstants.tokenKey);
  }

  // User Data Management
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _preferences.setString(AppConstants.userKey, jsonString);
  }

  static Map<String, dynamic>? getUserData() {
    final jsonString = _preferences.getString(AppConstants.userKey);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<void> clearUserData() async {
    await _preferences.remove(AppConstants.userKey);
  }

  // Login Status
  static Future<void> setLoggedIn(bool value) async {
    await _preferences.setBool(AppConstants.isLoggedInKey, value);
  }

  static bool isLoggedIn() {
    return _preferences.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // General Key-Value Storage
  static Future<void> saveString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  static String? getString(String key) {
    return _preferences.getString(key);
  }

  static Future<void> saveInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  static int? getInt(String key) {
    return _preferences.getInt(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  // Clear All Data
  static Future<void> clearAll() async {
    await _preferences.clear();
  }
}
