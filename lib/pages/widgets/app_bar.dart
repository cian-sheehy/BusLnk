import 'package:bus_lnk/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../maps/stop_map.dart';

class AppBarWidget extends StatelessWidget with PreferredSizeWidget {
  AppBarWidget(this.alerts);

  final List alerts;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Widget _buildPopupDialog(BuildContext context) => AlertDialog(
        contentPadding: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        title: TextButton.icon(
          onPressed: null,
          icon: Icon(
            Icons.bus_alert,
            color: Theme.of(context).textTheme.headline2.color,
          ),
          label: Text(
            'Service alert information',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).textTheme.headline2.color,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: alerts.length,
            itemBuilder: (BuildContext context, int index) {
              var header =
                  alerts[index]['header_text']['translation'][0]['text'];
              var description =
                  alerts[index]['description_text']['translation'][0]['text'];
              var doesUrlExist = alerts[index].containsKey('url') as bool;
              var severityLevel = alerts[index]['severity_level'];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      top: 6,
                      bottom: 6,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        onTap: doesUrlExist
                            ? () {
                                var url = alerts[index]['url']['translation'][0]
                                    ['text'];
                                Utils.launchURL(
                                  url.toString(),
                                );
                              }
                            : null,
                        title: Text(
                          header,
                          style: TextStyle(
                            color:
                                Utils.calculateBannerAlertColour(severityLevel),
                          ),
                        ),
                        subtitle: Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.subtitle1.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).textTheme.headline2.color,
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'BusLnk',
        ),
        actions: [
          ModalRoute.of(context).settings.name == '/stop' && alerts.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.error_outline,
                    color: Colors.orange[600],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: _buildPopupDialog,
                    );
                  },
                )
              : Container(),
          ModalRoute.of(context).settings.name == '/map' ||
                  ModalRoute.of(context).settings.name == '/stop' ||
                  ModalRoute.of(context).settings.name == '/servicemap'
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.map_rounded,
                  ),
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      '/map',
                      arguments: StopsMapArguments(
                        LatLng(
                          -41.276825,
                          174.777969,
                        ),
                        true,
                      ),
                    );
                  },
                ),
          ModalRoute.of(context).settings.name == '/'
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.home_rounded,
                  ),
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName(Navigator.defaultRouteName),
                    );
                  },
                )
        ],
      );
}
