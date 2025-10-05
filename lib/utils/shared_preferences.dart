import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<SharedPreferences> _getPrefsInstance() async {
    return SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await _getPrefsInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _getPrefsInstance();
    return prefs.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await _getPrefsInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _getPrefsInstance();
    return prefs.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await _getPrefsInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _getPrefsInstance();
    return prefs.getBool(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await _getPrefsInstance();
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await _getPrefsInstance();
    await prefs.clear();
  }
}