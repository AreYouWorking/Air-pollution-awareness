// get current location using Geolocator
import 'dart:convert';

import 'package:app/location/userposition.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<Position> getCurrentLocation() async {
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
  return await Geolocator.getCurrentPosition();
}

Future<String> getCurrentPlaceName() async {
  String base = "https://api.bigdatacloud.net/data/reverse-geocode-client?";
  String param =
      "latitude=${Userposition.latitude.toString()}&longitude=${Userposition.longitude.toString()}&localityLanguage=en";
  final response = await http.get(Uri.parse(base + param));

  final parsed = jsonDecode(response.body)["city"];
  return parsed;
}
