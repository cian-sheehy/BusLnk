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
        child: Column(
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
                  splashRadius: Theme.of(context).switchTheme.splashRadius,
                  activeColor:
                      Theme.of(context).toggleButtonsTheme.selectedColor,
                  onChanged: (value) {
                    setState(() {
                      myTheme.switchTheme();
                    });
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Text(
                  'Help',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  bottom: 20,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'v1.2',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
