import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';

import '../themes/theme.dart';

const openApiBaseUrl = 'https://api.opendata.metlink.org.nz/v1/gtfs';
const openRealTimeApiBaseUrl = 'https://api.opendata.metlink.org.nz/v1/gtfs-rt';
const backendApiBaseUrl = 'https://backend.metlink.org.nz/api/v1';

Options headerOptions = Options(
  headers: {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'x-api-key': '766wnmFs3m3wpgAEm2qjR6LNRs5J6uhg6tCHxkpH'
  },
);

MyTheme myTheme = MyTheme();
final LocalStorage storage = LocalStorage('BusLnk');
