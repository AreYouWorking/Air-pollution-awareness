// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofeed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
      json['status'] as String,
      Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      json['aqi'] as int,
      json['idx'] as int,
      (json['attributions'] as List<dynamic>)
          .map((e) => Attr.fromJson(e as Map<String, dynamic>))
          .toList(),
      City.fromJson(json['city'] as Map<String, dynamic>),
      json['dominentpol'] as String,
      Iaqi.fromJson(json['iaqi'] as Map<String, dynamic>),
      Time.fromJson(json['time'] as Map<String, dynamic>),
      Forecast.fromJson(json['forecast'] as Map<String, dynamic>),
      Debug.fromJson(json['debug'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'aqi': instance.aqi,
      'idx': instance.idx,
      'attributions': instance.attributions,
      'city': instance.city,
      'dominentpol': instance.dominentpol,
      'iaqi': instance.iaqi,
      'time': instance.time,
      'forecast': instance.forecast,
      'debug': instance.debug,
    };

Debug _$DebugFromJson(Map<String, dynamic> json) => Debug(
      json['sync'] as String,
    );

Map<String, dynamic> _$DebugToJson(Debug instance) => <String, dynamic>{
      'sync': instance.debug_sync,
    };

Attr _$AttrFromJson(Map<String, dynamic> json) => Attr(
      json['url'] as String,
      json['name'] as String,
    )..logo = json['logo'] as String?;

Map<String, dynamic> _$AttrToJson(Attr instance) => <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'logo': instance.logo,
    };

// this could be deleted by json_serializable
double toDouble(dynamic e) {
  if (e is String) {
    return double.parse(e);
  } else {
    return (e as num).toDouble();
  }
}

City _$CityFromJson(Map<String, dynamic> json) => City(
      (json['geo'] as List<dynamic>).map((e) => toDouble(e)).toList(),
      json['name'] as String,
      json['url'] as String,
      json['location'] as String,
    );

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'geo': instance.geo,
      'name': instance.name,
      'url': instance.url,
      'location': instance.location,
    };

Iaqi _$IaqiFromJson(Map<String, dynamic> json) => Iaqi(
      json['co'] == null
          ? null
          : IaqiValue.fromJson(json['co'] as Map<String, dynamic>),
      json['dew'] == null
          ? null
          : IaqiValue.fromJson(json['dew'] as Map<String, dynamic>),
      json['h'] == null
          ? null
          : IaqiValue.fromJson(json['h'] as Map<String, dynamic>),
      json['no2'] == null
          ? null
          : IaqiValue.fromJson(json['no2'] as Map<String, dynamic>),
      json['o3'] == null
          ? null
          : IaqiValue.fromJson(json['o3'] as Map<String, dynamic>),
      json['p'] == null
          ? null
          : IaqiValue.fromJson(json['p'] as Map<String, dynamic>),
      json['pm10'] == null
          ? null
          : IaqiValue.fromJson(json['pm10'] as Map<String, dynamic>),
      json['pm25'] == null
          ? null
          : IaqiValue.fromJson(json['pm25'] as Map<String, dynamic>),
      json['so2'] == null
          ? null
          : IaqiValue.fromJson(json['so2'] as Map<String, dynamic>),
      IaqiValue.fromJson(json['t'] as Map<String, dynamic>),
      IaqiValue.fromJson(json['w'] as Map<String, dynamic>),
      json['wg'] == null
          ? null
          : IaqiValue.fromJson(json['wg'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IaqiToJson(Iaqi instance) => <String, dynamic>{
      'co': instance.co,
      'dew': instance.dew,
      'h': instance.h,
      'no2': instance.no2,
      'o3': instance.o3,
      'p': instance.p,
      'pm10': instance.pm10,
      'pm25': instance.pm25,
      'so2': instance.so2,
      't': instance.t,
      'w': instance.w,
      'wg': instance.wg,
    };

IaqiValue _$IaqiValueFromJson(Map<String, dynamic> json) => IaqiValue(
      (json['v'] as num).toDouble(),
    );

Map<String, dynamic> _$IaqiValueToJson(IaqiValue instance) => <String, dynamic>{
      'v': instance.v,
    };

Time _$TimeFromJson(Map<String, dynamic> json) => Time(
      json['s'] as String,
      json['tz'] as String,
      json['v'] as int,
      json['iso'] as String,
    );

Map<String, dynamic> _$TimeToJson(Time instance) => <String, dynamic>{
      's': instance.s,
      'tz': instance.tz,
      'v': instance.v,
      'iso': instance.iso,
    };

Forecast _$ForecastFromJson(Map<String, dynamic> json) => Forecast(
      Daily.fromJson(json['daily'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
      'daily': instance.daily,
    };

Daily _$DailyFromJson(Map<String, dynamic> json) => Daily(
      (json['o3'] as List<dynamic>)
          .map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['pm10'] as List<dynamic>)
          .map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['pm25'] as List<dynamic>)
          .map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['uvi'] as List<dynamic>?)
          ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DailyToJson(Daily instance) => <String, dynamic>{
      'o3': instance.o3,
      'pm10': instance.pm10,
      'pm25': instance.pm25,
      'uvi': instance.uvi,
    };

DataPoint _$DataPointFromJson(Map<String, dynamic> json) => DataPoint(
      json['avg'] as int,
      json['day'] as String,
      json['max'] as int,
      json['min'] as int,
    );

Map<String, dynamic> _$DataPointToJson(DataPoint instance) => <String, dynamic>{
      'avg': instance.avg,
      'day': instance.day,
      'max': instance.max,
      'min': instance.min,
    };
