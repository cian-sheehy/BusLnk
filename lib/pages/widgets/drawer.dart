import 'package:flutter/material.dart';

import '../../constants/config.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer();

  @override
  NavDrawerState createState() => NavDrawerState();
}

class NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Text(
                  'Dark Mode',
                ),
                trailing: Switch(
                  value: isDarkTheme,
                  onChanged: (value) {
                    setState(() {
                      print(isDarkTheme);
                      isDarkTheme = value;
                      print(isDarkTheme);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      );
}
