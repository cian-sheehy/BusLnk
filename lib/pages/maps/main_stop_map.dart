import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/config.dart';
import '../stop/stop.dart';
import '../widgets/app_bar.dart';

class MainStopsMapArguments {
  final LatLng startingPoint;
  final Position position;
  final Map<Marker, Map<String, dynamic>> mapMarkers;
  final bool isStop;

  MainStopsMapArguments(
    this.startingPoint,
    this.position,
    this.mapMarkers,
    this.isStop,
  );
}

// Create a stateful widget
class MainStopsMapWidget extends StatefulWidget {
  final MainStopsMapArguments arguments;

  const MainStopsMapWidget(this.arguments);

  @override
  State<MainStopsMapWidget> createState() => MainStopsMapWidgetState();
}

class MainStopsMapWidgetState extends State<MainStopsMapWidget>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => locationUtils.isPermissionDenied
          ? _scaffoldMessengerKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  'Location permissions are disabled.',
                ),
                duration: Duration(
                  seconds: 3,
                ),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: widget.arguments.isStop ? AppBarWidget(null) : null,
          body: getBody(
            widget.arguments.startingPoint,
            locationUtils.isPermissionDenied ? null : widget.arguments.position,
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'relocation_${locationUtils.isPermissionDenied}',
            onPressed: () {
              if (locationUtils.isPermissionDenied) {
                locationUtils
                    .validateLocationPermissions(true)
                    .then((locationModel) {
                  setState(() {
                    locationUtils
                        .setPermissions(locationModel.isPermissionDenied);
                    locationUtils
                        .setPositionStream(locationModel.positionStream);

                    if (locationModel.isPermissionDenied) {
                      _scaffoldMessengerKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Location permissions have been denied. Some features are disabled.',
                          ),
                          duration: Duration(
                            seconds: 3,
                          ),
                        ),
                      );
                    }
                  });
                });
                if (!locationUtils.isPermissionDenied) {
                  _mapController.move(
                    LatLng(
                      widget.arguments.position.latitude,
                      widget.arguments.position.longitude,
                    ),
                    17,
                  );
                }
              } else {
                _mapController.move(
                  LatLng(
                    widget.arguments.position.latitude,
                    widget.arguments.position.longitude,
                  ),
                  17,
                );
              }
            },
            backgroundColor: Theme.of(context).buttonColor,
            child: Icon(
              locationUtils.isPermissionDenied
                  ? Icons.location_off
                  : Icons.my_location,
              color: Colors.white,
            ),
          ),
        ),
      );

  Widget getBody(LatLng startingPoint, Position position) => FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: startingPoint,
          zoom: locationUtils.isPermissionDenied ? 12 : 17,
          minZoom: 0,
          maxZoom: 19,
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          plugins: [
            MarkerClusterPlugin(),
          ],
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/buslnk/cktj6udbk040r17qw734nnw37/tiles/256/{z}/{x}/{y}@2x?access_token=sk.eyJ1IjoiYnVzbG5rIiwiYSI6ImNrdGo4anRwejE5bzcydXBhZzQwOGw0bXoifQ.lIhu3ETYdoy6GWIHESPhfQ',
            additionalOptions: {
              'accessToken':
                  'sk.eyJ1IjoiYnVzbG5rIiwiYSI6ImNrdGo4anRwejE5bzcydXBhZzQwOGw0bXoifQ.lIhu3ETYdoy6GWIHESPhfQ',
              'id': 'mapbox.mapbox-streets-v8',
            },
          ),
          MarkerLayerOptions(
            markers: position == null
                ? []
                : [
                    Marker(
                      width: 80,
                      height: 80,
                      point: LatLng(
                        position.latitude,
                        position.longitude,
                      ),
                      builder: (ctx) => Container(
                        decoration: BoxDecoration(
                          color: Colors.teal[100],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 30,
                          onPressed: null,
                          icon: Icon(
                            Icons.person_pin_rounded,
                            color: Theme.of(context).buttonColor,
                          ),
                        ),
                      ),
                    ),
                  ],
          ),
          MarkerClusterLayerOptions(
            maxClusterRadius: 200,
            disableClusteringAtZoom: 16,
            animationsOptions: AnimationsOptions(
              zoom: Duration(
                milliseconds: 200,
              ),
            ),
            size: Size(
              60,
              60,
            ),
            fitBoundsOptions: FitBoundsOptions(
              maxZoom: 19,
              padding: EdgeInsets.all(50),
            ),
            anchor: AnchorPos.align(
              AnchorAlign.center,
            ),
            markers: widget.arguments.mapMarkers.keys.toList(),
            polygonOptions: PolygonOptions(
              color: Colors.transparent,
              borderColor: Colors.transparent,
            ),
            popupOptions: PopupOptions(
              popupController: _popupController,
              popupBuilder: (_, marker) => Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: 200,
                height: 100,
                child: Card(
                  shape: Theme.of(context).cardTheme.shape,
                  color: Theme.of(context).cardTheme.color,
                  child: ListTile(
                    trailing: IconButton(
                      icon: Icon(
                        Icons.open_in_browser_rounded,
                        color: Theme.of(context).buttonColor,
                      ),
                      onPressed: () async {
                        var stop = widget.arguments.mapMarkers[marker];
                        await Navigator.pushNamed(
                          _scaffoldKey.currentContext,
                          '/stop',
                          arguments: StopArguments(
                            stop['stop_name'],
                            stop['stop_code'],
                          ),
                        );
                      },
                    ),
                    title: Text(
                      '${widget.arguments.mapMarkers[marker]['stop_name']}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.headline1.color,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${widget.arguments.mapMarkers[marker]['stop_code']}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle1.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            builder: (context, markers) => FloatingActionButton(
              heroTag: 'stop_hero_tag_${markers.length.toString()}',
              onPressed: null,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                markers.length.toString(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.subtitle2.color,
                ),
              ),
            ),
          ),
        ],
      );
}
