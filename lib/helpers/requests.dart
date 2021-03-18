import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import '../constants/config.dart';

dynamic getRequest(String url) async {
  var res = await Dio().get(
    url,
    options: headerOptions,
  );
  if (res.statusCode == 200) {
    return res.data;
  }
  return [] as dynamic;
}

dynamic getRequestCache(String url) async {
  var res = await Dio().get(
    url,
    options: buildCacheOptions(
      Duration(
        days: 1,
      ),
      options: headerOptions,
    ),
  );
  if (res.statusCode == 200) {
    return res.data;
  }
  return [] as dynamic;
}
