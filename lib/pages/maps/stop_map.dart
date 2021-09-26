import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/config.dart';
import '../../helpers/requests.dart';
import '../widgets/app_bar.dart';
import '../widgets/page_loading_dots.dart';
import 'main_stop_map.dart';

class StopsMapArguments {
  final LatLng location;
  final bool isStop;

  StopsMapArguments(
    this.location,
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List stops = [];
  List<Marker> listMarkers = [];
  Map<Marker, Map<String, dynamic>> mapMarkers = {};
  double latitude;
  double longitude;
  var geolocator = Geolocator();
  var locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  final permissionSnack = SnackBar(
    content: Text(
        'Location permissions have been denied. Some features are disabled.'),
    duration: Duration(
      seconds: 3,
    ),
  );

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

    fetchStopList();

    locationUtils.validateLocationPermissions(false).then((locationModel) {
      setState(() {
        locationUtils.setPermissions(locationModel.isPermissionDenied);
        locationUtils.setPositionStream(locationModel.positionStream);
      });
    });
  }

  @override
  void dispose() {
    stops?.clear();
    listMarkers?.clear();
    mapMarkers?.clear();
    super.dispose();
  }

  void fetchStopList() async {
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
    });
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: locationUtils.positionStream,
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          var showLoading =
              stops.isEmpty && listMarkers.isEmpty && snapshot.data == null;
          print(snapshot.data);

          if (showLoading) {
            return Scaffold(
              key: _scaffoldKey,
              appBar: widget.arguments.isStop ? AppBarWidget(null) : null,
              body: PageLoadingIndicator(),
            );
          }

          var startingPoint = !locationUtils.isPermissionDenied
              ? LatLng(
                  snapshot.data.latitude,
                  snapshot.data.longitude,
                )
              : LatLng(
                  widget.arguments.location.latitude,
                  widget.arguments.location.longitude,
                );

          return MainStopsMapWidget(
            MainStopsMapArguments(
              startingPoint,
              snapshot.data,
              mapMarkers,
              widget.arguments.isStop,
            ),
          );
        },
      );
}
