import 'package:geolocator/geolocator.dart';

class LocationModel {
  bool isPermissionDenied;
  Stream<Position> positionStream;

  LocationModel({
    this.isPermissionDenied,
    this.positionStream,
  });
}
