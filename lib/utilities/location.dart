import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../datamodels/location.model.dart';

class LocationUtilities with ChangeNotifier {
  bool _isPermissionDenied;
  Stream<Position> _positionStream;

  bool get isPermissionDenied => _isPermissionDenied;

  Stream<Position> get positionStream => _positionStream;

  Future<LocationModel> validateLocationPermissions(
    requestPermissions,
  ) async {
    // Test if location services are enabled.
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationModel(
        isPermissionDenied: !serviceEnabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (requestPermissions) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return LocationModel(
          isPermissionDenied: true,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return LocationModel(
        isPermissionDenied: true,
      );
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return LocationModel(
        isPermissionDenied: false,
        positionStream: Geolocator.getPositionStream(
          desiredAccuracy: LocationAccuracy.high,
        ),
      );
    }

    return LocationModel(
      isPermissionDenied: true,
    );
  }

  void setPermissions(bool isDenied) {
    _isPermissionDenied = isDenied;
    notifyListeners();
  }

  void setPositionStream(Stream<Position> s) {
    _positionStream = s;
    notifyListeners();
  }
}
