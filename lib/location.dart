import 'package:location/location.dart' as location;

import 'logger.dart';

class Location {
  static location.LocationData _locationData;
  static bool _serviceDisabled = false;
  static bool _permissionNotGranted = false;

  static Future<void> init() async {
    try {
      if (_serviceDisabled || _permissionNotGranted) return;
      var locationService = new location.Location();
      var serviceEnabled = await locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await locationService.requestService();
        if (!serviceEnabled) {
          logger.i("Geolocation service disabled");
          _serviceDisabled = true;
          return;
        }
      }

      var permissionGranted = await locationService.hasPermission();
      if (permissionGranted == location.PermissionStatus.denied) {
        permissionGranted = await locationService.requestPermission();
        if (permissionGranted != location.PermissionStatus.granted) {
          logger.w("Geolocation permission not granted");
          _permissionNotGranted = true;
          return;
        }
      }

      _locationData = await locationService.getLocation();
    } catch (e) {
      logger.e("Getting location exception", e);
    }
  }

  static bool get inited =>
      _locationData != null && !_serviceDisabled && !_permissionNotGranted;
  static double get latitude => _locationData?.latitude;
  static double get longitude => _locationData?.longitude;
  static double get altitude => _locationData?.altitude;
}
