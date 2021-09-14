import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/config.dart';
import '../../helpers/requests.dart';
import '../stop/stop.dart';
import '../widgets/app_bar.dart';
import '../widgets/page_loading_dots.dart';

class StopsMapArguments {
  final LatLng location;
  final bool isMap;
  final bool isStop;

  StopsMapArguments(
    this.location,
    this.isMap,
    this.isStop,
  );
}

// Create a stateful widget
class StopsMapWidget extends StatefulWidget {
  final StopsMapArguments arguments;

  const StopsMapWidget(this.arguments);

  @override
  State<StopsMapWidget> createState() => StopsMapWidgetState();
}

class StopsMapWidgetState extends State<StopsMapWidget>
    with TickerProviderStateMixin {
  final GlobalKey _scaffoldkey = GlobalKey();
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();
  List stops = [];
  bool isLoading = false;
  List<Marker> listMarkers = [];
  Map<Marker, Map<String, dynamic>> mapMarkers = {};
  double latitude;
  double longitude;
  var geolocator = Geolocator();
  var locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );
  var positionStream;

  @override
  void initState() {
    super.initState();
    Dio().interceptors.add(
          DioCacheManager(
            CacheConfig(
              baseUrl: 'https://api.opendata.metlink.org.nz',
              defaultRequestMethod: 'GET',
            ),
          ).interceptor,
        );

    validateLocationPermissions();
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
    );
    fetchStopList();
  }

  @override
  void dispose() {
    positionStream = null;
    stops?.clear();
    listMarkers?.clear();
    mapMarkers?.clear();
    super.dispose();
  }

  void fetchStopList() async {
    setState(() {
      isLoading = true;
    });

    var stopData = await getRequestCache(
      '$openApiGtsBaseUrl/stops',
    );
    setState(() {
      stops = stopData;
      stops.forEach((stop) {
        var marker = Marker(
          width: 100,
          height: 100,
          point: LatLng(
            stop['stop_lat'],
            stop['stop_lon'],
          ),
          builder: (ctx) => Icon(
            Icons.directions_bus_rounded,
            color: Theme.of(context).primaryColor,
            size: 40,
          ),
        );
        mapMarkers[marker] = stop;
        listMarkers.add(marker);
      });
      isLoading = false;
    });
  }

  Future validateLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: positionStream,
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
        if (stops.isEmpty || listMarkers.isEmpty || snapshot.data == null) {
          return Scaffold(
            key: _scaffoldkey,
            appBar: widget.arguments.isStop ? AppBarWidget(null) : null,
            body: PageLoadingIndicator(),
          );
        }

        var startingPoint = widget.arguments.location == null
            ? LatLng(
                snapshot.data.latitude,
                snapshot.data.longitude,
              )
            : LatLng(
                widget.arguments.location.latitude,
                widget.arguments.location.longitude,
              );

        return Scaffold(
          key: _scaffoldkey,
          appBar: widget.arguments.isStop ? AppBarWidget(null) : null,
          body: getBody(
            startingPoint,
            snapshot.data,
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'relocation',
            onPressed: () {
              _mapController.move(
                  LatLng(
                    snapshot.data.latitude,
                    snapshot.data.longitude,
                  ),
                  17);
            },
            backgroundColor: Theme.of(context).buttonColor,
            child: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        );
      });

  Widget getBody(LatLng startingPoint, Position position) => FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: startingPoint,
          zoom: 17,
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
            markers: [
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
            markers: mapMarkers.keys.toList(),
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
                        var stop = mapMarkers[marker];
                        await Navigator.pushNamed(
                          _scaffoldkey.currentContext,
                          '/stop',
                          arguments: StopArguments(
                            stop['stop_name'],
                            stop['stop_code'],
                          ),
                        );
                      },
                    ),
                    title: Text(
                      '${mapMarkers[marker]['stop_name']}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.headline1.color,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${mapMarkers[marker]['stop_code']}',
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
