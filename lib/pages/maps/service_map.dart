import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';

import '../../constants/config.dart';
import '../../helpers/requests.dart';
import '../stop/stop.dart';
import '../widgets/app_bar.dart';
import '../widgets/page_loading_dots.dart';

class ServiceMapArguments {
  final String routeID;
  final dynamic service;

  ServiceMapArguments(this.routeID, this.service);
}

// Create a stateful widget
class ServiceMapWidget extends StatefulWidget {
  final ServiceMapArguments arguments;

  const ServiceMapWidget(this.arguments);

  @override
  State<ServiceMapWidget> createState() => ServiceMapWidgetState();
}

class ServiceMapWidgetState extends State<ServiceMapWidget>
    with TickerProviderStateMixin {
  final GlobalKey _scaffoldkey = GlobalKey();
  final PopupController _popupController = PopupController();
  bool isLoading = false;
  List<Marker> listMarkers = [];
  List<Polyline> polyLines = [];
  Map<Marker, Map<String, dynamic>> mapMarkers = {};
  LatLng _hightlightedStop;

  List route = [];
  int stopindex;

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
    fetchRoute();
  }

  @override
  void dispose() {
    polyLines?.clear();
    listMarkers?.clear();
    mapMarkers?.clear();
    super.dispose();
  }

  void fetchRoute() async {
    setState(() {
      isLoading = true;
    });
    var routeData = await getRequestCache(
      '$openApiGtsBaseUrl/stops?route_id=${widget.arguments.routeID}',
    );

    setState(() {
      route = routeData as List<dynamic>;
      // var _points = <LatLng>[];
      route.forEach((stop) {
        var isCurrentStop = widget.arguments.service != null &&
            stop['stop_code'] == widget.arguments.service['stop_code'];
        if (isCurrentStop) {
          _hightlightedStop = LatLng(
            stop['stop_lat'],
            stop['stop_lon'],
          );
        }
        var marker = Marker(
          width: 40,
          height: 40,
          point: LatLng(
            stop['stop_lat'],
            stop['stop_lon'],
          ),
          builder: (ctx) => Icon(
            Icons.directions_bus_rounded,
            color: isCurrentStop
                ? Colors.yellow[900]
                : Theme.of(context).primaryColor,
            size: 40,
          ),
        );
        // _points.add(LatLng(
        //   route['stop_lat'],
        //   route['stop_lon'],
        // ));
        mapMarkers[marker] = stop;
        listMarkers.add(marker);
      });
      // polyLines.add(
      //   Polyline(
      //     points: _points,
      //     strokeWidth: 3,
      //     isDotted: true,
      //     color: Colors.blueGrey[800],
      //   ),
      // );
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldkey,
        appBar: AppBarWidget(),
        body: getBody(),
      );

  Widget getBody() {
    if (isLoading || route.isEmpty || listMarkers.isEmpty) {
      return PageLoadingIndicator();
    }
    var isZoomed = widget.arguments.service != null;
    return FlutterMap(
      options: MapOptions(
        center: isZoomed
            ? _hightlightedStop
            : LatLng(
                route[0]['stop_lat'],
                route[0]['stop_lon'],
              ),
        zoom: isZoomed ? 15 : 11,
        minZoom: 0,
        maxZoom: 19,
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        plugins: [
          MarkerClusterPlugin(),
        ],
      ),
      layers: [
        TileLayerOptions(
          // https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png
          // https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
          urlTemplate: 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
          subdomains: [
            'a',
            'b',
            'c',
          ],
        ),
        // PolylineLayerOptions(
        //   polylines: polyLines,
        // ),
        MarkerClusterLayerOptions(
          maxClusterRadius: 200,
          disableClusteringAtZoom: 10,
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
              width: 200,
              height: 100,
              child: Card(
                shape: Theme.of(context).cardTheme.shape,
                color: Theme.of(context).cardTheme.color,
                child: ListTile(
                  trailing: IconButton(
                    icon: Icon(
                      Icons.open_in_browser_rounded,
                      color: Theme.of(context).toggleButtonsTheme.selectedColor,
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
            heroTag: 'service_hero_tag_${markers.length.toString()}',
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
}
