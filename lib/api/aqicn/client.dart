import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part "geofeed.g.dart";

const base = "https://api.waqi.info/feed/geo";

Future<http.Response> geofeedLatLng(
    String lat, String long, String token) async {
  String params = ":$lat;$long/?token=$token";

  print(base + params);
  return http.get(Uri.parse(base + params));
}

Future<Data> getData(String lat, String long) async {
  var token = dotenv.env["AQICN_KEY"];
  if (token == null) {
    throw Exception("Please set AQICN_KEY in .env file");
  }
  http.Response resp = await geofeedLatLng(lat, long, token);
  return Response.fromJson(jsonDecode(resp.body)).data;
}

@JsonSerializable()
class Response {
  final String status;
  final Data data;

  Response(this.status, this.data);

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}

@JsonSerializable()
class Data {
  final int aqi;
  final int idx;
  final List<Attr> attributions;
  final City city;
  final String dominentpol;
  final Iaqi iaqi;
  final Time time;
  final Forecast forecast;
  final Debug debug;

  Data(this.aqi, this.idx, this.attributions, this.city, this.dominentpol,
      this.iaqi, this.time, this.forecast, this.debug);

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class Debug {
  @JsonKey(name: "sync")
  final String debug_sync;

  Debug(this.debug_sync);

  factory Debug.fromJson(Map<String, dynamic> json) => _$DebugFromJson(json);
  Map<String, dynamic> toJson() => _$DebugToJson(this);
}

@JsonSerializable()
class Attr {
  final String url;
  final String name;
  String? logo;

  Attr(this.url, this.name);
  factory Attr.fromJson(Map<String, dynamic> json) => _$AttrFromJson(json);
  Map<String, dynamic> toJson() => _$AttrToJson(this);
}

@JsonSerializable()
class City {
  final List<double> geo;
  final String name;
  final String url;
  final String location;

  City(this.geo, this.name, this.url, this.location);
  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);
}

@JsonSerializable()
class Iaqi {
  final IaqiValue co;
  final IaqiValue dew;
  final IaqiValue h;
  final IaqiValue no2;
  final IaqiValue o3;
  final IaqiValue p;
  final IaqiValue pm10;
  final IaqiValue pm25;
  final IaqiValue so2;
  final IaqiValue t;
  final IaqiValue w;

  Iaqi(this.co, this.dew, this.h, this.no2, this.o3, this.p, this.pm10,
      this.pm25, this.so2, this.t, this.w);
  factory Iaqi.fromJson(Map<String, dynamic> json) => _$IaqiFromJson(json);
  Map<String, dynamic> toJson() => _$IaqiToJson(this);
}

@JsonSerializable()
class IaqiValue {
  final double v;

  IaqiValue(this.v);
  factory IaqiValue.fromJson(Map<String, dynamic> json) =>
      _$IaqiValueFromJson(json);
  Map<String, dynamic> toJson() => _$IaqiValueToJson(this);
}

@JsonSerializable()
class Time {
  final String s;
  final String tz;
  final int v;
  final String iso;

  Time(this.s, this.tz, this.v, this.iso);
  factory Time.fromJson(Map<String, dynamic> json) => _$TimeFromJson(json);
  Map<String, dynamic> toJson() => _$TimeToJson(this);
}

@JsonSerializable()
class Forecast {
  final Daily daily;

  Forecast(this.daily);
  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);
  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable()
class Daily {
  final List<DataPoint> o3;
  final List<DataPoint> pm10;
  final List<DataPoint> pm25;
  final List<DataPoint>? uvi;

  Daily(this.o3, this.pm10, this.pm25, this.uvi);
  factory Daily.fromJson(Map<String, dynamic> json) => _$DailyFromJson(json);
  Map<String, dynamic> toJson() => _$DailyToJson(this);
}

@JsonSerializable()
class DataPoint {
  final int avg;
  final String day;
  final int max;
  final int min;

  DataPoint(this.avg, this.day, this.max, this.min);
  factory DataPoint.fromJson(Map<String, dynamic> json) =>
      _$DataPointFromJson(json);
  Map<String, dynamic> toJson() => _$DataPointToJson(this);
}
