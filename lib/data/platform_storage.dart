import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Cross-platform key-value storage.
/// Uses SharedPreferences on all platforms (works on web too via shared_preferences_web).
class PlatformStorage {
  static SharedPreferences? _prefs;

  /// Must be called once before any read/write, typically in main().
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  static bool get isWeb => kIsWeb;
}
