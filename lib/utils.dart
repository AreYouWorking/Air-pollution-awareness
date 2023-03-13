// get current location using Geolocator
import 'dart:convert';

import 'package:app/location/userposition.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<Position> fetchCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request location');
  }

  // May return the cache position as expected.
  // Wait for a little while before seeing location change.
  // https://github.com/Baseflow/flutter-geolocator/issues/884
  return await Geolocator.getCurrentPosition();
}

Future<String> fetchPlaceName(String lat, String lon) async {
  String base = "https://api.bigdatacloud.net/data/reverse-geocode-client?";
  String param = "latitude=$lat&longitude=$lon&localityLanguage=en";
  final response = await http.get(Uri.parse(base + param));

  final parsed = jsonDecode(response.body)["city"];
  return parsed;
}

Future<void> fetchAndSetUserLocation() async {
  Position pos = await fetchCurrentLocation();
  String placeName =
      await fetchPlaceName(pos.latitude.toString(), pos.longitude.toString());
  Userposition.setCurrentLocation(
      pos.latitude.toString(), pos.longitude.toString(), placeName);
}
