import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHelper {
  static Future<LatLng> getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    // If the user has not yet granted permission, we must ask for it
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // If they still deny permission throw error
      if (permission == LocationPermission.denied) {
        throw Exception('User denied Location permission');
      }
      // If the user has not denied permission continue and return location
    }
    // If permission already granted return location
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  static LatLng getRandomPosition() {
    return LatLng(getRandomLat(), getRandomLong());
  }

  static double getRandomLat() {
    final random = Random();
    final latitude = -90 + random.nextDouble() * 90 * 2;
    return latitude;
  }

  static double getRandomLong() {
    final random = Random();
    final longitude = -180 + random.nextDouble() * 180 * 2;
    return longitude;
  }
}
