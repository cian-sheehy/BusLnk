// import 'package:flutter/material.dart';

// import '../constants/config.dart';

// class MyTheme with ChangeNotifier {
//   bool _isDark = false;

//   bool get darkTheme => _isDark;

//   MyTheme() {
//     storage.ready.then((_) {
//       if (storage.getItem('currentTheme') == null) {
//         storage.setItem(
//           'currentTheme',
//           _isDark,
//         );
//       }
//       _isDark = storage.getItem('currentTheme');
//       print(_isDark);
//     });
//   }

//   ThemeMode currentTheme() => _isDark ? ThemeMode.dark : ThemeMode.light;

//   set darkTheme(bool value) {
//     storage.ready.then((_) {
//       _isDark = value;
//       storage.setItem(
//         'currentTheme',
//         value,
//       );
//       notifyListeners();
//     });
//   }
// }
