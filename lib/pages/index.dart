import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';

import '../constants/config.dart';
import '../datamodels/favourites.dart';
import '../helpers/requests.dart';
import '../helpers/utils.dart';
import 'maps/service_map.dart';
import 'stop/stop.dart';
import 'widgets/app_bar.dart';
import 'widgets/card.dart';
import 'widgets/drawer.dart';
import 'widgets/page_loading_dots.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final GlobalKey _scaffoldkey = GlobalKey();
  List stops = [];
  List newStops = [];
  List routes = [];
  List newRoutes = [];
  bool isLoading = false;
  bool initialized = false;
  bool showRouteData = false;
  bool showStopData = false;
  bool showFavourites = false;

  FavouriteItem _editingFavItem;

  final FavouriteList favouriteList = FavouriteList();
  final TextEditingController _textController = TextEditingController();
  TextEditingController _popUpTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // currentTheme.addListener(() {
    //   print('Them changes');
    //   setState(() {});
    // });
    Dio().interceptors.add(
          DioCacheManager(
            CacheConfig(
              baseUrl: 'https://api.opendata.metlink.org.nz',
              defaultRequestMethod: 'GET',
            ),
          ).interceptor,
        );
    fetchStopList();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildPopupDialog(BuildContext context) => AlertDialog(
        title: Text('Edit stop name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              autofocus: true,
              keyboardType: TextInputType.text,
              controller: _popUpTextController,
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              _updateItem(
                _editingFavItem,
                _popUpTextController.text.trim(),
              );
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      );

  void fetchStopList() async {
    setState(() {
      _textController.clear();
      isLoading = true;
      showRouteData = false;
      showFavourites = false;
      showStopData = true;
    });

    var stopData = await getRequestCache(
      '$openApiBaseUrl/stops',
    );

    setState(() {
      stops = stopData as List<dynamic>;
      newStops = List.from(stops);
      isLoading = false;
    });
  }

  void fetchRouteList() async {
    setState(() {
      _textController.clear();
      isLoading = true;
      showRouteData = true;
      showFavourites = false;
      showStopData = false;
    });

    var routeData = await getRequestCache(
      '$openApiBaseUrl/routes',
    );

    setState(() {
      routes = routeData as List<dynamic>;
      newRoutes = List.from(routes);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldkey,
        appBar: AppBarWidget(),
        drawer: NavDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            if (showRouteData) {
              fetchRouteList();
            } else if (showStopData) {
              fetchStopList();
            }
          },
          child: getBody(),
        ),
        floatingActionButton: showFavourites && !isLoading
            ? FloatingActionButton(
                heroTag: 'favourite_hero_tag',
                onPressed: () {
                  // Add your onPressed code here!
                  setState(() {
                    _clearStorage();
                    showFavourites = false;
                    fetchStopList();
                  });
                },
                backgroundColor: Colors.blueGrey[800],
                child: Icon(
                  Icons.delete,
                ),
              )
            : null,
      );

  void _addItem(String stopName, String stopNum) {
    setState(() {
      final item = FavouriteItem(
        stopName: stopName,
        stopNum: stopNum,
      );
      var exists = favouriteList.items.any(
        (fav) => fav.stopNum == stopNum,
      );
      if (!exists) {
        favouriteList.items.add(item);
        _saveToStorage();
      }
    });
  }

  void _updateItem(FavouriteItem favItem, String updatedText) {
    setState(() {
      var index = favouriteList.items.indexWhere(
        (fav) =>
            fav.stopNum == favItem.stopNum && fav.stopName == favItem.stopName,
      );
      favItem.stopName = updatedText;
      favouriteList.items[index] = FavouriteItem(
        stopName: updatedText,
        stopNum: favItem.stopNum,
      );
      _saveToStorage();
    });
  }

  void _clearSearch() {
    _textController.clear();
    setState(() {
      newStops = stops;
      newRoutes = routes;
    });
  }

  void _getItems() async {
    await storage.ready.then((_) async {
      if (!initialized) {
        var items = await storage.getItem('favourites');
        if (items != null) {
          setState(() {
            favouriteList.items = List<FavouriteItem>.from(
              (items as List).map(
                (item) => FavouriteItem(
                  stopName: item['stopName'].toString(),
                  stopNum: item['stopNum'].toString(),
                ),
              ),
            );
            initialized = true;
            if (favouriteList.items.isNotEmpty) {
              showFavourites = true;
              showRouteData = false;
              showStopData = false;
            }
          });
        }
      }
    });
  }

  void _remoteItem(String stopName, String stopNum) {
    setState(() {
      favouriteList.items.removeWhere(
        (file) => file.stopNum == stopNum && file.stopName == stopName,
      );
      _saveToStorage();
    });
  }

  void _saveToStorage() {
    storage.ready.then(
      (_) => storage.setItem(
        'favourites',
        favouriteList.toJSONEncodable(),
      ),
    );
  }

  void _clearStorage() {
    setState(() {
      storage.clear();
      favouriteList.items =
          storage.getItem('favourites') as List<FavouriteItem> ?? [];
    });
  }

  Widget getBody() => FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null || stops.contains(null) || stops.isEmpty) {
            return Center(
              child: JumpingDotsProgressIndicator(),
            );
          }
          _getItems();

          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Container(
                  padding: EdgeInsets.only(left: 15, top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey[300],
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: TextField(
                    enabled: !isLoading,
                    keyboardType: TextInputType.text,
                    controller: _textController,
                    onSubmitted: (value) async {
                      if (newStops.isNotEmpty) {
                        await Navigator.pushNamed(
                          _scaffoldkey.currentContext,
                          '/stop',
                          arguments: StopArguments(
                            newStops[0]['stop_name'].toString(),
                            newStops[0]['stop_id'].toString(),
                          ),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: isLoading
                          ? 'Loading..'
                          : showRouteData
                              ? 'Search route number...'
                              : 'Search stop...',
                      suffixIcon: IconButton(
                        onPressed: () {
                          _clearSearch();
                          setState(() {
                            showRouteData
                                ? newRoutes = routes
                                : newStops = stops;
                          });
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                        ),
                      ),
                    ),
                    onChanged: showRouteData ? onRouteChanged : onStopChanged,
                  ),
                ),
              ),
              Switch(
                value: isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    print(isDarkTheme);
                    isDarkTheme = value;
                    print(isDarkTheme);
                  });
                },
              ),
              Container(
                height: 50,
                child: ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    favouriteList.items.isNotEmpty
                        ? ButtonTheme(
                            minWidth: 80,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: Colors.blueGrey[300],
                                  ),
                                ),
                                primary: showFavourites
                                    ? Colors.blueGrey[200]
                                    : Colors.blueGrey[500],
                              ),
                              onPressed: () {
                                setState(() {
                                  showFavourites = true;
                                  showRouteData = false;
                                  showStopData = false;
                                });
                              },
                              child: Text(
                                'Favourites (${favouriteList.items.length})',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          )
                        : null,
                    ButtonTheme(
                      minWidth: 80,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.blueGrey[300],
                            ),
                          ),
                          primary: showStopData
                              ? Colors.blueGrey[200]
                              : Colors.blueGrey[500],
                        ),
                        onPressed: () {
                          fetchStopList();
                        },
                        child: Text(
                          'Stops',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 80,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.blueGrey[300],
                            ),
                          ),
                          primary: showRouteData
                              ? Colors.blueGrey[200]
                              : Colors.blueGrey[500],
                        ),
                        onPressed: () {
                          fetchRouteList();
                        },
                        child: Text(
                          'Routes',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              showStopData && !isLoading
                  ? Text(
                      '${newStops.length} stops',
                    )
                  : Container(),
              showRouteData && !isLoading
                  ? Text(
                      '${newRoutes.length} routes',
                    )
                  : Container(),
              isLoading
                  ? JumpingDotsProgressIndicator()
                  : Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        key: UniqueKey(),
                        padding: EdgeInsets.all(12.0),
                        children: showRouteData
                            ? newRoutes
                                .map((route) => Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          color: Utils.hexToColor(
                                            route['route_color'].toString(),
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          print(route);
                                          await Navigator.pushNamed(
                                            _scaffoldkey.currentContext,
                                            '/servicemap',
                                            arguments: ServiceMapArguments(
                                              route['route_id'].toString(),
                                              null,
                                            ),
                                          );
                                        },
                                        trailing: Icon(
                                          Icons.alt_route_rounded,
                                          color: Colors.blueGrey[800],
                                        ),
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Utils.hexToColor(
                                              route['route_color'].toString(),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          margin: EdgeInsets.only(
                                            right: 10,
                                          ),
                                          child: Center(
                                            child: Text(
                                              // Read the name field value and set it in the Text widget
                                              route['route_short_name']
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              // set some style to text
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Utils.hexToColor(
                                                  route['route_text_color']
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: RichText(
                                          text: TextSpan(
                                            text: route['route_long_name']
                                                .toString(),
                                            style: TextStyle(
                                              color: Utils.hexToColor(
                                                route['route_color'].toString(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList()
                            : showFavourites
                                ? favouriteList.items.map((favourite) {
                                    var stopExistsInFavourites =
                                        favouriteList.items.any(
                                      (file) =>
                                          file.stopNum == favourite.stopNum,
                                    );
                                    return CardWidget(
                                      title: favourite.stopName,
                                      subtitle: favourite.stopNum,
                                      trailingIcon: IconButton(
                                        onPressed: () {
                                          print(favourite);
                                          _popUpTextController =
                                              TextEditingController(
                                            text: favourite.stopName,
                                          );
                                          _editingFavItem = favourite;
                                          showDialog(
                                            context: context,
                                            builder: _buildPopupDialog,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Color(0xff699b2c),
                                        ),
                                      ),
                                      leadingIcon: IconButton(
                                        onPressed: () {
                                          print(favourite);
                                          setState(() {
                                            if (stopExistsInFavourites) {
                                              _remoteItem(
                                                favourite.stopName.toString(),
                                                favourite.stopNum.toString(),
                                              );
                                              if (favouriteList.items.isEmpty) {
                                                fetchStopList();
                                              }
                                            } else {
                                              _addItem(
                                                favourite.stopName,
                                                favourite.stopNum,
                                              );
                                            }
                                          });
                                          _clearSearch();
                                        },
                                        icon: Icon(
                                          stopExistsInFavourites
                                              ? Icons.star
                                              : Icons.star_border,
                                        ),
                                      ),
                                      callback: () async {
                                        print(favourite.stopName);
                                        await Navigator.pushNamed(
                                          _scaffoldkey.currentContext,
                                          '/stop',
                                          arguments: StopArguments(
                                            favourite.stopName,
                                            favourite.stopNum,
                                          ),
                                        );
                                      },
                                    );
                                  }).toList()
                                : newStops.map((stop) {
                                    var stopExistsInFavourites =
                                        favouriteList.items.any(
                                      (file) =>
                                          file.stopNum ==
                                          stop['stop_id'].toString(),
                                    );
                                    return CardWidget(
                                      title: stop['stop_name'].toString(),
                                      subtitle: stop['stop_id'].toString(),
                                      leadingIcon: Icon(
                                        Icons.directions_bus_rounded,
                                        color: Color(0xff699b2c),
                                      ),
                                      trailingIcon: IconButton(
                                        onPressed: () {
                                          print(stop);
                                          setState(() {
                                            if (stopExistsInFavourites) {
                                              _remoteItem(
                                                stop['stop_name'].toString(),
                                                stop['stop_id'].toString(),
                                              );
                                            } else {
                                              _addItem(
                                                stop['stop_name'].toString(),
                                                stop['stop_id'].toString(),
                                              );
                                            }
                                            _clearSearch();
                                          });
                                        },
                                        icon: Icon(
                                          stopExistsInFavourites
                                              ? Icons.star
                                              : Icons.star_border,
                                        ),
                                      ),
                                      callback: () async {
                                        print(stop);
                                        await Navigator.pushNamed(
                                          _scaffoldkey.currentContext,
                                          '/stop',
                                          arguments: StopArguments(
                                            stop['stop_name'].toString(),
                                            stop['stop_id'].toString(),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                      ),
                    )
            ],
          );
        },
      );

  void onStopChanged(String searchText) {
    setState(() {
      showFavourites = false;
      final fuse = Fuzzy(
        stops,
        options: FuzzyOptions(
          findAllMatches: true,
          threshold: .3,
          keys: [
            WeightedKey(
              getter: (i) => i['stop_id'].toString(),
              weight: 0.5,
              name: 'stop_id',
            ),
            WeightedKey(
              getter: (i) => i['stop_name'].toString(),
              weight: 0.5,
              name: 'stop_name',
            ),
          ],
        ),
      );
      var result = fuse.search(searchText);

      newStops = [];
      result.forEach((res) {
        newStops.add(res.item);
      });
    });
  }

  void onRouteChanged(String searchText) {
    setState(() {
      final fuse = Fuzzy(
        routes,
        options: FuzzyOptions(
          findAllMatches: true,
          threshold: .3,
          keys: [
            WeightedKey(
              getter: (route) => route['route_short_name'].toString(),
              weight: 1,
              name: 'route_short_name',
            ),
          ],
        ),
      );
      var result = fuse.search(searchText);

      newRoutes = [];
      result.forEach((res) {
        newRoutes.add(res.item);
      });
    });
  }
}
