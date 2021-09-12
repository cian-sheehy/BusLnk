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
  int _currentIndex = 0;
  List stops = [];
  List newStops = [];
  List routes = [];
  List newRoutes = [];
  bool initialized = false;
  bool _validate = false;

  FavouriteItem _editingFavItem;

  final FavouriteList favouriteList = FavouriteList();
  final TextEditingController _textController = TextEditingController();
  TextEditingController _popUpTextController = TextEditingController();

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
  }

  @override
  void dispose() {
    _textController?.dispose();
    _popUpTextController?.dispose();
    newRoutes?.clear();
    newStops?.clear();
    stops?.clear();
    routes?.clear();
    super.dispose();
  }

  void onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 1 && (stops.isEmpty)) {
        fetchStopList();
      }
      if (_currentIndex == 2 && (routes.isEmpty)) {
        fetchRouteList();
      }
    });
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
              decoration: InputDecoration(
                hintText: 'Enter custom name',
              ),
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
              setState(() {
                _popUpTextController.text.isEmpty
                    ? _validate = true
                    : _validate = false;
              });
              if (!_validate) {
                _updateItem(
                  _editingFavItem,
                  _popUpTextController.text.trim(),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      );

  void fetchStopList() async {
    setState(() {
      stops?.clear();
      _textController?.clear();
    });

    var stopData = await getRequestCache(
      '$openApiGtsBaseUrl/stops',
    );

    setState(() {
      stops = stopData as List<dynamic>;
      newStops = List.from(stops);
    });
  }

  void fetchRouteList() async {
    setState(() {
      routes?.clear();
      _textController?.clear();
    });

    var routeData = await getRequestCache(
      '$openApiGtsBaseUrl/routes',
    );

    setState(() {
      routes = routeData as List<dynamic>;
      newRoutes = List.from(routes);
    });
  }

  @override
  Widget build(BuildContext context) {
    var _currentPage = [getFavouriteBody(), getStopBody(), getRouteBody()];

    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBarWidget(),
      drawer: NavDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onBottomNavTapped,
        selectedFontSize: 15,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 0 ? Icons.star : Icons.star_outline,
            ),
            label: favouriteList.items.isEmpty
                ? 'Favourites'
                : 'Favourites (${favouriteList.items.length})',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1
                  ? Icons.directions_bus
                  : Icons.directions_bus_outlined,
            ),
            label: 'Stops',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.alt_route : Icons.alt_route_outlined,
            ),
            label: 'Routes',
          ),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).cardColor,
        color: Theme.of(context).toggleButtonsTheme.selectedColor,
        onRefresh: () async {
          if (_currentIndex == 1) {
            fetchStopList();
          }
          if (_currentIndex == 2) {
            fetchRouteList();
          }
        },
        child: _currentPage[_currentIndex],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              heroTag: 'favourite_hero_tag',
              onPressed: () {
                // Add your onPressed code here!
                setState(() {
                  _clearStorage();
                  fetchStopList();
                });
              },
              backgroundColor: Theme.of(context).buttonColor,
              child: Icon(
                Icons.delete,
              ),
            )
          : null,
    );
  }

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
    _textController?.clear();
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
          });
        }
      }
    });
  }

  void _removeItem(String stopName, String stopNum) {
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
      storage?.clear();
      favouriteList.items =
          storage.getItem('favourites') as List<FavouriteItem> ?? [];
    });
  }

  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = favouriteList.items.removeAt(oldindex);
      favouriteList.items.insert(newindex, items);
      _saveToStorage();
    });
  }

  Widget getFavouriteBody() => FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: PageLoadingIndicator(),
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
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        setState(() {
                          _currentIndex = 1;
                        });
                      }
                    },
                    child: TextField(
                      enabled: stops.isNotEmpty,
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
                        hintText: 'Search stop...',
                      ),
                      onChanged: onStopChanged,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ReorderableListView(
                  onReorder: reorderData,
                  shrinkWrap: true,
                  // key: UniqueKey(),
                  padding: EdgeInsets.all(12.0),
                  children: favouriteList.items.map((favourite) {
                    var stopExistsInFavourites = favouriteList.items.any(
                      (file) => file.stopNum == favourite.stopNum,
                    );
                    return CardWidget(
                      key: ValueKey(favourite),
                      title: favourite.stopName,
                      subtitle: favourite.stopNum,
                      trailingIcon: IconButton(
                        onPressed: () {
                          _popUpTextController = TextEditingController(
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
                          color: Theme.of(context)
                              .toggleButtonsTheme
                              .selectedColor,
                        ),
                      ),
                      leadingIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            if (stopExistsInFavourites) {
                              _removeItem(
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
                          color: Theme.of(context).buttonColor,
                        ),
                      ),
                      onTapCallback: () async {
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
                  }).toList(),
                ),
              ),
            ],
          );
        },
      );

  Widget getStopBody() {
    var isLoading = stops.isEmpty;
    if (isLoading) {
      return Center(
        child: PageLoadingIndicator(),
      );
    }

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
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              enabled: !isLoading,
              autofocus: true,
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
                hintText: isLoading ? 'Loading..' : 'Search stop...',
                suffixIcon: _textController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _clearSearch();
                          setState(() {
                            newStops = stops;
                          });
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                        ),
                      ),
              ),
              onChanged: onStopChanged,
            ),
          ),
        ),
        isLoading
            ? PageLoadingIndicator()
            : Flexible(
                child: ListView(
                shrinkWrap: true,
                key: UniqueKey(),
                padding: EdgeInsets.all(12.0),
                children: newStops.map((stop) {
                  var stopExistsInFavourites = favouriteList.items.any(
                    (file) => file.stopNum == stop['stop_id'].toString(),
                  );
                  return CardWidget(
                    title: stop['stop_name'].toString(),
                    subtitle: stop['stop_id'].toString(),
                    leadingIcon: Icon(
                      Icons.directions_bus_rounded,
                      color: Theme.of(context).toggleButtonsTheme.selectedColor,
                      size: 30,
                    ),
                    trailingIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          if (stopExistsInFavourites) {
                            _removeItem(
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
                        stopExistsInFavourites ? Icons.star : Icons.star_border,
                        color: Theme.of(context).buttonColor,
                      ),
                    ),
                    onTapCallback: () async {
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
              )),
      ],
    );
  }

  Widget getRouteBody() {
    var isLoading = routes.isEmpty;
    if (isLoading) {
      return Center(
        child: PageLoadingIndicator(),
      );
    }

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
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              enabled: !isLoading,
              autofocus: true,
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
                hintText: isLoading ? 'Loading..' : 'Search route number...',
                suffixIcon: _textController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _clearSearch();
                          setState(() {
                            newRoutes = routes;
                          });
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                        ),
                      ),
              ),
              onChanged: onRouteChanged,
            ),
          ),
        ),
        isLoading
            ? PageLoadingIndicator()
            : Flexible(
                child: ListView(
                  shrinkWrap: true,
                  key: UniqueKey(),
                  padding: EdgeInsets.all(12.0),
                  children: newRoutes
                      .map((route) => Card(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                              side: BorderSide(
                                color: Utils.hexToColor(
                                  route['route_color'].toString(),
                                ),
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              onTap: () async {
                                await Navigator.pushNamed(
                                  _scaffoldkey.currentContext,
                                  '/servicemap',
                                  arguments: ServiceMapArguments(
                                    route['route_id'].toString(),
                                    null,
                                  ),
                                );
                              },
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
                                    route['route_short_name'].toString(),
                                    textAlign: TextAlign.center,
                                    // set some style to text
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  text: route['route_long_name'].toString(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        .color,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
      ],
    );
  }

  void onStopChanged(String searchText) {
    setState(() {
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
