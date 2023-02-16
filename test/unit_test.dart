import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';

import 'package:app/openmetro/airquality.dart';
import 'package:intl/intl.dart';

import 'package:app/location/selectlocation.dart';

void main() {
  group('[Unit_Test] [AirQualityAPI]', () {
    test('fetchAirQuality returns success response', () async {
      // CMU's location
      const lat = "18.80465";
      const long = "98.9550117";
      final now = DateTime.now();
      final formatter = DateFormat("yyyy-MM-dd");
      final startDate = formatter.format(now);
      final endDate = formatter.format(now.add(const Duration(days: 5)));
      final resp = await fetchAitQuality(lat, long, startDate, endDate);
      expect(resp.statusCode, 200);
    });

    test('getAirQuality5day returns success response', () async {
      // CMU's location
      const lat = "18.80465";
      const long = "98.9550117";
      final airquality = await getAirQuality5day(lat, long);
      expect(airquality.hourly_units, isNotNull);
      expect(airquality.hourly, isNotNull);
    });

    test('fromJson creates valid Airquality object', () {
      final map = {
        "latitude": 18.800003,
        "longitude": 98.80002,
        "generationtime_ms": 0.3420114517211914,
        "utc_offset_seconds": 25200,
        "timezone": "Asia/Bangkok",
        "timezone_abbreviation": "+07",
        "hourly_units": {"time": "iso8601", "us_aqi_pm2_5": "USAQI"},
        "hourly": {
          "time": ["2022-02-12T00:00:00.000Z", "2022-02-12T01:00:00.000Z"],
          "us_aqi_pm2_5": [74, 75]
        }
      };
      final airquality = Airquality.fromJson(map);
      expect(airquality.latitude, 18.800003);
      expect(airquality.longitude, 98.80002);
      expect(airquality.generationtime_ms, 0.3420114517211914);
      expect(airquality.utc_offset_seconds, 25200);
      expect(airquality.timezone, "Asia/Bangkok");
      expect(airquality.timezone_abbreviation, "+07");
      expect(airquality.hourly_units.time, "iso8601");
      expect(airquality.hourly_units.us_aqi_pm2_5, "USAQI");
      expect(airquality.hourly.time,
          ["2022-02-12T00:00:00.000Z", "2022-02-12T01:00:00.000Z"]);
      expect(airquality.hourly.us_aqi_pm2_5, [74, 75]);
    });
  });

  group('[Unit_Test] [Location]', () {
    final json = {
      'name': 'Test Location',
      'city': 'Test City',
      'lat': 37.7749,
      'lon': -122.4194,
      'distance': 10.0,
    };
    final location = Suggestlocation.fromJson(json);

    test(
        'fromJson() should return a Suggestlocation object with correct values',
        () {
      expect(location.name, json['name']);
      expect(location.city, json['city']);
      expect(location.lat, json['lat']);
      expect(location.lon, json['lon']);
      expect(location.distance, json['distance']);
    });

    test('should return a list of Suggestlocation objects', () {
      const json = '''
        {
          "results": [
            {
              "name": "Location 1",
              "city": "City 1",
              "lat": 40.7128,
              "lon": -74.0060,
              "distance": 5.0
            },
            {
              "name": "Location 2",
              "city": "City 2",
              "lat": 37.7749,
              "lon": -122.4194,
              "distance": 10.0
            }
          ]
        }
      ''';
      final expectedLocations = [
        const Suggestlocation(
          name: "Location 1",
          city: "City 1",
          lat: 40.7128,
          lon: -74.0060,
          distance: 5.0,
        ),
        const Suggestlocation(
          name: "Location 2",
          city: "City 2",
          lat: 37.7749,
          lon: -122.4194,
          distance: 10.0,
        ),
      ];

      final actualLocations = parseJson(json);

      expect(actualLocations.elementAt(0).name,
          expectedLocations.elementAt(0).name);
      expect(actualLocations.elementAt(0).city,
          expectedLocations.elementAt(0).city);
      expect(
          actualLocations.elementAt(0).lat, expectedLocations.elementAt(0).lat);
      expect(
          actualLocations.elementAt(0).lon, expectedLocations.elementAt(0).lon);
      expect(actualLocations.elementAt(0).distance,
          expectedLocations.elementAt(0).distance);

      expect(actualLocations.elementAt(1).name,
          expectedLocations.elementAt(1).name);
      expect(actualLocations.elementAt(1).city,
          expectedLocations.elementAt(1).city);
      expect(
          actualLocations.elementAt(1).lat, expectedLocations.elementAt(1).lat);
      expect(
          actualLocations.elementAt(1).lon, expectedLocations.elementAt(1).lon);
      expect(actualLocations.elementAt(1).distance,
          expectedLocations.elementAt(1).distance);
    });
  });
}
