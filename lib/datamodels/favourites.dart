class FavouriteItem {
  String stopName;
  String stopNum;

  FavouriteItem({
    this.stopName,
    this.stopNum,
  });

  Map<String, dynamic> toJSONEncodable() {
    var m = <String, dynamic>{};

    m['stopName'] = stopName;
    m['stopNum'] = stopNum;

    return m;
  }
}

class FavouriteList {
  List<FavouriteItem> items;

  FavouriteList() {
    items = [];
  }

  List<Map<String, dynamic>> toJSONEncodable() => items
      .map(
        (item) => item.toJSONEncodable(),
      )
      .toList();
}
