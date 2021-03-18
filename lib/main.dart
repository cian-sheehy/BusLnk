import 'package:flutter/material.dart';

import 'constants/config.dart';
import 'pages/index.dart';
import 'pages/maps/service_map.dart';
import 'pages/maps/stop_map.dart';
import 'pages/routes/route.dart';
import 'pages/stop/stop.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MainApp();
}

class MainApp extends StatefulWidget {
  const MainApp({
    Key key,
  });

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: _getRoute,
        theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
        // darkTheme: ThemeData.dark(),
        // themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      );
}

Route _getRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return _buildRoute(
        settings,
        IndexPage(),
      );
    case '/map':
      return _buildRoute(
        settings,
        StopsMapWidget(
          settings.arguments,
        ),
      );
    case '/servicemap':
      return _buildRoute(
        settings,
        ServiceMapWidget(
          settings.arguments,
        ),
      );
    case '/stop':
      return _buildRoute(
        settings,
        StopWidget(
          settings.arguments,
        ),
      );
    case '/route':
      return _buildRoute(
        settings,
        RouteWidget(
          settings.arguments,
        ),
      );
    default:
      return null;
  }
}

MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) =>
    MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
    );
