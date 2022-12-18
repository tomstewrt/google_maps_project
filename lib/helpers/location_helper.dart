import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position> getCurrentLocation() async {
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
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
