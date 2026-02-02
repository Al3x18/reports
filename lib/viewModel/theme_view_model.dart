import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for app theme. Holds theme mode and persistence.
class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel({required ThemeMode initialMode}) {
    _themeMode = initialMode;
  }

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themePreference', mode.toString());
    notifyListeners();
  }
}
