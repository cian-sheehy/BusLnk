import 'package:bus_lnk/utilities/location.dart';
import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';

import '../utilities/theme.dart';

const openApiGtsBaseUrl = 'https://api.opendata.metlink.org.nz/v1/gtfs';
const openApiBaseUrl = 'https://api.opendata.metlink.org.nz/v1';
const openRealTimeApiBaseUrl = 'https://api.opendata.metlink.org.nz/v1/gtfs-rt';
const backendApiBaseUrl = 'https://backend.metlink.org.nz/api/v1';

Options headerOptions = Options(
  headers: {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'x-api-key': String.fromEnvironment('API_KEY')
  },
);

MyTheme myTheme = MyTheme();
LocationUtilities locationUtils = LocationUtilities();
final LocalStorage storage = LocalStorage('BusLnk');
