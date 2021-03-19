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
  void initState() {
    super.initState();
    myTheme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: _getRoute,
        theme: ThemeData(
          brightness: Brightness.light,
          buttonColor: Colors.blueGrey[800],
          textTheme: TextTheme(
            headline1: TextStyle(
              color: Colors.black,
            ),
            headline2: TextStyle(
              color: Color(0xff699b2c),
            ),
            subtitle1: TextStyle(
              color: Colors.black,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.blueGrey[100],
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          textTheme: TextTheme(
            headline2: TextStyle(
              color: Color(0xff699b2c),
            ),
          ),
          cardColor: Colors.blueGrey[800],
          buttonColor: Colors.orange[300],
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.blueGrey[800],
          ),
        ),
        themeMode: myTheme.currentTheme(),
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
