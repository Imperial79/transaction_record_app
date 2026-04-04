import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // We assume Hive is already initialized in main.dart
    final box = Hive.box('hiveBox');
    final String? theme = box.get('theme');
    return _mapStringToThemeMode(theme ?? 'System');
  }

  ThemeMode _mapStringToThemeMode(String theme) {
    switch (theme) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get themeString {
    switch (state) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }

  Future<void> setTheme(String themeStr) async {
    final box = Hive.box('hiveBox');
    await box.put('theme', themeStr);
    state = _mapStringToThemeMode(themeStr);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
