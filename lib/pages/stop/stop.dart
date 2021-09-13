import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/config.dart';
import '../../helpers/requests.dart';
import '../../helpers/utils.dart';
import '../maps/service_map.dart';
import '../maps/stop_map.dart';
import '../widgets/app_bar.dart';
import '../widgets/card.dart';
import '../widgets/no_stop_information.dart';
import '../widgets/page_loading_dots.dart';

class StopArguments {
  final String stopName;
  final String stopNumber;

  StopArguments(this.stopName, this.stopNumber);
}

// Create a stateful widget
class StopWidget extends StatefulWidget {
  final StopArguments arguments;

  const StopWidget(this.arguments);

  @override
  State<StopWidget> createState() => StopWidgetState();
}

class StopWidgetState extends State<StopWidget> with TickerProviderStateMixin {
  final GlobalKey _scaffoldkey = GlobalKey();
  List services = [];
  List routes = [];
  List alerts = [];
  dynamic stopInfo;
  dynamic serviceAlerts;
  bool isLoading = false;
  String lastUpdated;
  String stopNumber;

  @override
  void initState() {
    super.initState();
    fetchStop();
  }

  @override
  void dispose() {
    routes?.clear();
    services?.clear();
    alerts?.clear();
    serviceAlerts?.clear();
    stopInfo?.clear();
    super.dispose();
  }

  void fetchStop() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        stopNumber = widget.arguments.stopNumber;
        lastUpdated = Utils.getCurrentTime();
        stopInfo = [];
        routes = [];
        services = [];
        alerts = [];
        serviceAlerts = [];
      });
    }
    // Get stop information
    var stopData = await getRequest(
      '$backendApiBaseUrl/stops/${widget.arguments.stopNumber}',
    );
    // Get route information
    var routeData = await getRequest(
      '$openApiGtsBaseUrl/routes',
    );
    // Get route information
    var serviceAlertData = await getRequest(
      '$openRealTimeApiBaseUrl/servicealerts',
    );
    // Get depatures
    var depaturesData = await getRequest(
      '$openApiBaseUrl/stop-predictions?stop_id=${widget.arguments.stopNumber}',
    );

    if (mounted) {
      setState(() {
        stopInfo = stopData;
        routes = routeData as List<dynamic>;
        serviceAlerts = serviceAlertData['entity'] as List<dynamic>;
        services = depaturesData['departures'] as List<dynamic>;
        if (serviceAlerts.isNotEmpty) {
          for (var entity in serviceAlerts) {
            var alert = entity['alert'];
            if (alert.containsKey('informed_entity')) {
              alert['informed_entity'].where((a) {
                if (a.containsKey('stop_id')) {
                  if (a['stop_id'].toLowerCase() == stopInfo['stop_id']) {
                    alerts.add(alert);
                    return true;
                  }
                }
                if (a.containsKey('route_id')) {
                  var ele = stopData['route_ids']
                      .toList()
                      .where((id) => a['route_id'] == id);
                  if (ele.length >= 1 && !alerts.contains(alert)) {
                    alert['severitySortOrder'] =
                        Utils.severitySortOrder(alert['severity_level']);
                    alerts.add(alert);
                    return true;
                  }
                }
                return false;
              }).toList();
            }
          }
        }
        alerts.sort(
            (a, b) => a['severitySortOrder'].compareTo(b['severitySortOrder']));
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldkey,
        appBar: AppBarWidget(
          alerts,
        ),
        body: RefreshIndicator(
          backgroundColor: Theme.of(context).cardColor,
          color: Theme.of(context).toggleButtonsTheme.selectedColor,
          onRefresh: () async {
            fetchStop();
          },
          child: getBody(),
        ),
      );

  Widget getBody() {
    if (stopInfo == null || stopInfo.length == 0 || serviceAlerts == null) {
      return PageLoadingIndicator();
    }
    if ((services == null || services.isEmpty || routes == null) &&
        !isLoading) {
      return Column(
        children: <Widget>[
          NoStopInformationWidget(
            stopNumber: stopNumber,
            stopName: stopInfo['stop_name'].toString(),
            lastUpdated: lastUpdated,
          )
        ],
      );
    }
    String _newFormattedDate;
    int _firstDateIdx;
    return Column(
      children: <Widget>[
        CardWidget(
          title: stopInfo['stop_name'].toString(),
          subtitle:
              'Stop ${stopInfo['stop_id'].toString()}, last updated at $lastUpdated',
          trailingIcon: IconButton(
            padding: EdgeInsets.only(
              right: 20,
            ),
            icon: Icon(
              Icons.map_rounded,
              size: 30,
              color: Theme.of(context).buttonColor,
            ),
            onPressed: () async {
              await Navigator.pushNamed(
                _scaffoldkey.currentContext,
                '/map',
                arguments: StopsMapArguments(
                  LatLng(
                    stopInfo['stop_lat'],
                    stopInfo['stop_lon'],
                  ),
                  false,
                ),
              );
            },
          ),
        ),
        isLoading
            ? PageLoadingIndicator()
            : Expanded(
                child: ListView(
                  key: UniqueKey(),
                  padding: EdgeInsets.all(12.0),
                  children: services.asMap().entries.map((entry) {
                    var index = entry.key;
                    var service = entry.value;
                    Duration departureDuration;
                    DateTime _time;
                    var isDue = false;
                    var hasStatus =
                        service['status'] != null && service['status'] != '';
                    var isCancelled =
                        hasStatus && service['status'] == 'cancelled';
                    var isExpected = service['departure']['expected'] == null ||
                        service['departure']['expected'] == '';

                    if (!isExpected) {
                      departureDuration = Utils.departureDuration(service);
                      isDue = departureDuration.inSeconds < 120;
                    } else {
                      _time = DateTime.parse(
                        service['departure']['aimed'].toString(),
                      ).toLocal();
                    }

                    var isWheelChairAccessble =
                        service['wheelchair_accessible'] as bool;

                    var _formattedDate = DateFormat('EEE, d MMM').format(
                      DateTime.parse(
                        service['departure']['aimed'].toString(),
                      ).toLocal(),
                    );

                    dynamic route = Utils.findRoute(
                      routes,
                      service['service_id'].toString(),
                    );
                    var routeColor = Colors.blue[600];
                    var routeTextColor = Colors.white;

                    if (route.isNotEmpty) {
                      routeColor =
                          Utils.hexToColor(route[0]['route_color'].toString());
                      routeTextColor = Utils.hexToColor(
                          route[0]['route_text_color'].toString());
                    }

                    if (_formattedDate != _newFormattedDate) {
                      _newFormattedDate = _formattedDate;
                      _firstDateIdx = index;
                    }
                    return Column(
                      children: [
                        Visibility(
                          visible: index == _firstDateIdx,
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 15,
                            ),
                            child: Text(
                              _formattedDate,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            boxShadow: isCancelled
                                ? null
                                : [
                                    BoxShadow(
                                      color: routeColor,
                                      spreadRadius: 2,
                                    ),
                                  ],
                          ),
                          child: Opacity(
                            opacity: isCancelled ? .4 : 1,
                            child: ListTile(
                              onTap: isCancelled
                                  ? null
                                  : () async {
                                      await Navigator.pushNamed(
                                        _scaffoldkey.currentContext,
                                        '/servicemap',
                                        arguments: ServiceMapArguments(
                                          route[0]['route_id'].toString(),
                                          stopInfo,
                                        ),
                                      );
                                    },
                              contentPadding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 2,
                                top: 2,
                              ),
                              title: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: routeColor,
                                        shape: BoxShape.circle,
                                      ),
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Center(
                                        child: Text(
                                          // Read the name field value and set it in the Text widget
                                          service['service_id'].toString(),
                                          textAlign: TextAlign.center,
                                          // set some style to text
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                routeTextColor == Colors.black
                                                    ? Colors.white
                                                    : routeTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        service['destination']['name']
                                            .toString(),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: isWheelChairAccessble,
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        margin: const EdgeInsets.only(left: 5),
                                        child: IconButton(
                                          iconSize: 20,
                                          icon: Icon(
                                            Icons.accessible_forward,
                                            color: routeColor,
                                          ),
                                          onPressed: null,
                                        ),
                                      ),
                                    ),
                                    isCancelled
                                        ? Container(
                                            width: 120,
                                            height: 30,
                                            margin: const EdgeInsets.only(
                                              left: 5,
                                              bottom: 5,
                                            ),
                                            child: Center(
                                              child: Text(
                                                'CANCELLED',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                width: 75,
                                                height: 30,
                                                margin: const EdgeInsets.only(
                                                  left: 5,
                                                  bottom: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    !isExpected
                                                        ? isDue
                                                            ? 'Due'
                                                            : '${departureDuration.inMinutes} mins'
                                                        : isDue
                                                            ? 'Due'
                                                            : Utils.setTime(
                                                                _time),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )
      ],
    );
  }
}
