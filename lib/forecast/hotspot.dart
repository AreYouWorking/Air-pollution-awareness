import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../location/userposition.dart';

class HotspotData {
  final String? name;
  final String? city;
  final double lat;
  final double lon;
  final double distance;

  const HotspotData({
    required this.name,
    required this.city,
    required this.lat,
    required this.lon,
    required this.distance,
  });

  factory HotspotData.fromJson(Map<String, dynamic> json) {
    return HotspotData(
      name: json['name'] ?? json['state'] as String,
      city: json['city'] ?? json['state'] as String,
      lat: json['lat'] as double,
      lon: json['lon'] as double,
      distance: json['distance'] as double,
    );
  }
}

const searchRadiusInKm = 100;

Future<int> parseCSV(List csv) async {
  int numberHotspot = 0;
  for (var i = 1; i < csv.length; i++) {
    String a = csv[i];
    List x = a.split(',');
    double distance = await calDistance(
        double.parse('${x[1]}'),
        double.parse(Userposition.latitudeChosen),
        double.parse('${x[2]}'),
        double.parse(Userposition.longitudeChosen));
    if (distance < searchRadiusInKm) {
      numberHotspot++;
    }
  }
  print("numberHotspot");
  print(numberHotspot);
  return numberHotspot;
}

Future<double> calDistance(
    double lat1, double lat2, double lon1, double lon2) async {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  double distan = 12742 * asin(sqrt(a));
  return distan;
// Latitude: 1 deg = 110.574 km
// Longitude: 1 deg = 111.320*cos(latitude) km
}

Future<int> searchHotspot() async {
  var token = dotenv.env["FIRMS_KEY"];
  if (token == null) {
    throw Exception("Please set GEOAPI_KEY in .env file");
  }
  int resp = await fetchHotspot(token);
  // print(resp);

  return resp;
}

Future<int> fetchHotspot(String token) async {
  const base = "https://firms.modaps.eosdis.nasa.gov/api/country/csv/";
  String source = "VIIRS_SNPP_NRT";
  String th = "THA";

  var now = DateTime.now();
  String y = now.year.toString();
  String m = now.month.toString();
  String d = (now.day - 1).toString(); //because today no data !!

  String params = "$token/$source/$th/1/$y-$m-$d";
  print(base + params);
  final response = await http.get(Uri.parse(base + params));
  if (response.statusCode == 200) {
    // print(response.body.toString().split('THA'));
    int hotspot = await parseCSV(response.body.toString().split('THA'));

    return hotspot;
  } else {
    throw Exception("Failed to load location.");
  }
}
