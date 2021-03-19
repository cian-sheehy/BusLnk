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
            Container(
              padding: EdgeInsets.only(
                left: 20,
                bottom: 20,
                top: 40,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      right: 20,
                    ),
                    child: Icon(
                      Icons.settings,
                    ),
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: ListTile(
                onTap: () {
                  setState(() {
                    myTheme.switchTheme();
                  });
                },
                leading: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                trailing: Switch(
                  value: myTheme.darkTheme,
                  onChanged: (value) {
                    setState(() {
                      myTheme.switchTheme();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      );
}
