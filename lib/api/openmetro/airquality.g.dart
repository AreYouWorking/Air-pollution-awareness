// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Airquality _$AirqualityFromJson(Map<String, dynamic> json) => Airquality(
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
      (json['generationtime_ms'] as num).toDouble(),
      json['utc_offset_seconds'] as int,
      json['timezone'] as String,
      json['timezone_abbreviation'] as String,
      HourlyUnits.fromJson(json['hourly_units'] as Map<String, dynamic>),
      Hourly.fromJson(json['hourly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AirqualityToJson(Airquality instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'generationtime_ms': instance.generationtime_ms,
      'utc_offset_seconds': instance.utc_offset_seconds,
      'timezone': instance.timezone,
      'timezone_abbreviation': instance.timezone_abbreviation,
      'hourly_units': instance.hourly_units,
      'hourly': instance.hourly,
    };

HourlyUnits _$HourlyUnitsFromJson(Map<String, dynamic> json) => HourlyUnits(
      json['time'] as String,
      json['us_aqi_pm2_5'] as String,
    );

Map<String, dynamic> _$HourlyUnitsToJson(HourlyUnits instance) =>
    <String, dynamic>{
      'time': instance.time,
      'us_aqi_pm2_5': instance.us_aqi_pm2_5,
    };

Hourly _$HourlyFromJson(Map<String, dynamic> json) => Hourly(
      (json['time'] as List<dynamic>).map((e) => e as String).toList(),
      (json['us_aqi_pm2_5'] as List<dynamic>).map((e) => e as int?).toList(),
    );

Map<String, dynamic> _$HourlyToJson(Hourly instance) => <String, dynamic>{
      'time': instance.time,
      'us_aqi_pm2_5': instance.us_aqi_pm2_5,
    };
