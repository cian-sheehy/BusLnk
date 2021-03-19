import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../constants/config.dart';
import '../../helpers/extensions.dart';
import '../../helpers/requests.dart';
import '../../helpers/utils.dart';
import '../widgets/app_bar.dart';
import '../widgets/page_loading_dots.dart';

class RouteArguments {
  final String routeID;
  final String stopID;
  final String status;
  final Color colour;

  RouteArguments(this.routeID, this.stopID, this.status, this.colour);
}

// Create a stateful widget
class RouteWidget extends StatefulWidget {
  final RouteArguments arguments;

  const RouteWidget(this.arguments);

  @override
  State<RouteWidget> createState() => RouteWidgetState();
}

class RouteWidgetState extends State<RouteWidget>
    with TickerProviderStateMixin {
  List route = [];
  bool isLoading = false;
  String routeID;
  String stopID;
  Color colourCode;
  int stopindex;

  final scrollDirection = Axis.vertical;

  AutoScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(
        0,
        0,
        0,
        MediaQuery.of(context).padding.bottom,
      ),
      axis: scrollDirection,
    );
    fetchRoute();
  }

  Future _scrollToIndex(int index) async {
    await controller.scrollToIndex(index,
        preferPosition: AutoScrollPosition.middle,
        duration: Duration(
          milliseconds: 200,
        ));
  }

  int findStopIndex() => route.indexOf(
        route
            .where((stop) => stop['stop_id'].toLowerCase() == stopID)
            .toList()[0],
      );

  void fetchRoute() async {
    setState(() {
      isLoading = true;
      routeID = widget.arguments.routeID;
      stopID = widget.arguments.stopID;
      colourCode = widget.arguments.colour;
    });
    var routeData = await getRequest(
      '$openApiBaseUrl/stops?route_id=$routeID',
    );
    setState(() {
      route = routeData as List<dynamic>;
      isLoading = false;
    });
    if (stopID != null) {
      stopindex = findStopIndex();
      await _scrollToIndex(stopindex);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBarWidget(),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchRoute();
          },
          child: getBody(),
        ),
      );

  Widget getBody() {
    if (isLoading || route == null || route.isEmpty) {
      return PageLoadingIndicator();
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            key: UniqueKey(),
            scrollDirection: scrollDirection,
            controller: controller,
            padding: EdgeInsets.all(10.0),
            children: route.asMap().entries.map((entry) {
              var index = entry.key;
              var stop = entry.value;
              return AutoScrollTag(
                key: ValueKey(index),
                controller: controller,
                index: index,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          child: IconButton(
                            iconSize: 35,
                            icon: Icon(
                              Icons.circle,
                              color: index == stopindex
                                  ? Colors.deepPurple[300]
                                  : colourCode,
                            ),
                            onPressed: () {
                              print(stop);
                            },
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "${stop["stop_name"]}\n${stop["stop_id"]}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                        index == stopindex && widget.arguments.status != null
                            ? Container(
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Utils.calculateStatusColour(
                                    widget.arguments.status,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                margin: const EdgeInsets.only(left: 30),
                                child: Center(
                                  child: Text(
                                    // Read the name field value and set it in the Text widget
                                    widget.arguments.status
                                        .toString()
                                        .capitalise(),
                                    textAlign: TextAlign.right,
                                    // set some style to text
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Utils.calculateStatusTextColour(
                                        widget.arguments.status,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    index == (route.length - 1)
                        ? Container()
                        : Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: VerticalDivider(
                                  thickness: 3,
                                  indent: 0,
                                  endIndent: 0,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
