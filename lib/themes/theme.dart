import 'package:flutter/material.dart';

import '../constants/config.dart';

class MyTheme with ChangeNotifier {
  bool _isDark = ThemeMode.system == ThemeMode.dark;

  bool get darkTheme => _isDark;

  MyTheme() {
    storage.ready.then((_) {
      if (storage.getItem('currentTheme') == null) {
        storage.setItem(
          'currentTheme',
          _isDark,
        );
      }
      _isDark = storage.getItem('currentTheme');
      notifyListeners();
    });
  }

  ThemeMode currentTheme() => _isDark ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    _isDark = !_isDark;
    storage.setItem('currentTheme', _isDark);
    notifyListeners();
  }
}
