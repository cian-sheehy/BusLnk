import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';

const openApiBaseUrl = 'https://api.opendata.metlink.org.nz/v1/gtfs';
const backendApiBaseUrl = 'https://backend.metlink.org.nz/api/v1';

Options headerOptions = Options(
  headers: {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'x-api-key': '766wnmFs3m3wpgAEm2qjR6LNRs5J6uhg6tCHxkpH'
  },
);

// MyTheme currentTheme = MyTheme();
bool isDarkTheme = false;
final LocalStorage storage = LocalStorage('BusLnk');
