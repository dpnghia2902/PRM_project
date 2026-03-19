import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  red,
  blue,
  green,
  purple,
  orange,
}

class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = "app_theme";
  AppTheme _theme = AppTheme.red;

  AppTheme get theme => _theme;

  ThemeData getThemeData() {
    switch (_theme) {
      case AppTheme.red:
        return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red), useMaterial3: true);
      case AppTheme.blue:
        return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true);
      case AppTheme.green:
        return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: true);
      case AppTheme.purple:
        return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple), useMaterial3: true);
      case AppTheme.orange:
        return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), useMaterial3: true);
      default:
        return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red), useMaterial3: true);
    }
  }

  Future<void> setTheme(AppTheme newTheme) async {
    print("🔄 BEFORE: $_theme → $newTheme");
    _theme = newTheme;
    notifyListeners();
    print("✅ NOTIFY CALLED");
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, newTheme.index);
      print("💾 SAVED: ${newTheme.index}");
    } catch (e) {
      print("❌ Save error: $e");
    }
  }

  Future<void> loadTheme() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? index = prefs.getInt(_prefKey);
      print("📂 Loaded index: $index");
      
      if (index != null && index < AppTheme.values.length) {
        _theme = AppTheme.values[index];
        print("✅ LOADED: $_theme");
      }
      notifyListeners();
    } catch (e) {
      print("❌ Load error: $e");
    }
  }
}
