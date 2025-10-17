import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/strings.dart';
import '../screens/auth_page.dart';
import '../screens/main_navigation.dart';

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

  static Future<void> checkLoginStatus({BuildContext? context}) async {
    final String? token = await StorageService.getString(AppStrings.authToken);

    if (token != null && token.isNotEmpty) {
      if (context != null && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } else {
      clearAll();
      if (context != null && context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
              (route) => false,
        );
      }
    }
  }
}