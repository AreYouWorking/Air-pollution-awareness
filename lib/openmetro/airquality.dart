import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'airquality.g.dart';
// flutter pub run build_runner build --delete-conflicting-outputs

Future<http.Response> fetchAitQuality(String lat, String long, String startDate, String endDate) async {
  const base = "https://air-quality-api.open-meteo.com/v1/air-quality";
  String params =
      "?latitude=$lat&longitude=$long&hourly=us_aqi_pm2_5&timezone=Asia%2FBangkok&start_date=$startDate&end_date=$endDate";
  
  return http.get(Uri.parse(base + params));
}

Future<Airquality> getAirQuality5day(String lat, String long) async {
  final now = DateTime.now();
  final formatter = DateFormat("yyyy-MM-dd");
  final startDate = formatter.format(now);
  final endDate = formatter.format(now.add(const Duration(days: 5)));

  http.Response resp = await fetchAitQuality(lat, long, startDate, endDate);

  return Airquality.fromJson(jsonDecode(resp.body));
}

@JsonSerializable()
class Airquality {
  final double latitude;
  final double longitude;
  final double generationtime_ms;
  final int utc_offset_seconds;
  final String timezone;
  final String timezone_abbreviation;
  final HourlyUnits hourly_units;
  final Hourly hourly;

  Airquality(this.latitude, this.longitude, this.generationtime_ms,
      this.utc_offset_seconds, this.timezone, this.timezone_abbreviation, this.hourly_units, this.hourly);
  
  factory Airquality.fromJson(Map<String, dynamic> json) => _$AirqualityFromJson(json);
  Map<String, dynamic> toJson() => _$AirqualityToJson(this);
}

// this is not general for all parameters
@JsonSerializable()
class HourlyUnits {
  final String time;
  final String us_aqi_pm2_5;

  HourlyUnits(this.time, this.us_aqi_pm2_5);
  
  factory HourlyUnits.fromJson(Map<String, dynamic> json) => _$HourlyUnitsFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyUnitsToJson(this);
}

// this is not general for all parameters
@JsonSerializable()
class Hourly {
  final List<String> time;
  final List<int?> us_aqi_pm2_5;

  Hourly(this.time, this.us_aqi_pm2_5);

  factory Hourly.fromJson(Map<String, dynamic> json) => _$HourlyFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyToJson(this);
}
