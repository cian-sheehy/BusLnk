import 'package:bus_lnk/pages/widgets/page_loading_dots.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants/config.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer();

  @override
  NavDrawerState createState() => NavDrawerState();
}

class NavDrawerState extends State<NavDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<PackageInfo> packageInformation() async =>
      await PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: packageInformation(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: PageLoadingIndicator(),
          );
        }
        return Drawer(
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
                      snapshot.data.version,
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
      });
}
