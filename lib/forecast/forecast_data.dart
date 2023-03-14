import 'dart:async';

import 'package:app/api/aqicn/geofeed.dart';
import 'package:app/api/openmetro/airquality.dart';
import 'package:app/forecast/daily.dart';
import 'package:app/forecast/hourly.dart';
import 'package:app/forecast/today.dart';
import 'package:app/style.dart' as style;
import 'package:flutter/cupertino.dart';

import 'hotspot.dart';

DailyData _fromAqi(int aqi, DateTime datetime) {
  if (aqi <= 50) {
    return DailyData(style.aqiColor[0], "😍", aqi, "Good", datetime);
  } else if (aqi <= 100) {
    return DailyData(style.aqiColor[1], "😐", aqi, "Moderate", datetime);
  } else if (aqi <= 150) {
    return DailyData(
        style.aqiColor[2], "🙁", aqi, "Unhealthy \n for some", datetime);
  } else if (aqi <= 200) {
    return DailyData(style.aqiColor[3], "😨", aqi, "Unhealthy", datetime);
  } else if (aqi <= 300) {
    return DailyData(style.aqiColor[4], "😱", aqi, "Very Unhealthy", datetime);
  }
  return DailyData(
      style.aqiColor[5], "😵", aqi, "Hazardous", datetime);
}

class ForecastData {
  Airquality? openmeteo;
  Data? aqicn;
  DateTime? created;
  int? hotspot = 0;

  ForecastData({this.openmeteo, this.aqicn, this.created, this.hotspot});

  static Future<ForecastData> init(String lat, String long) async {
    final openmetro = await getAirQuality5day(lat, long);
    final aqicn = await getData(lat, long);
    final hotspot = await searchHotspot();
    return ForecastData(
        created: DateTime.parse(aqicn.time.iso).toLocal(),
        openmeteo: openmetro,
        aqicn: aqicn,
        hotspot: hotspot);
  }

  List<DailyData>? getDailyDatas() {
    if (aqicn == null) {
      return null;
    }

    var now = DateTime.now();
    List<DailyData> result = [_fromAqi(aqicn!.aqi, now)];
    // following this scale https://aqicn.org/scale/
    for (var v in aqicn!.forecast.daily.pm25) {
      var datetime = DateTime.parse(v.day);
      if (datetime.isAfter(now)) {
        result.add(_fromAqi(v.avg, datetime));
      }
    }
    return result;
  }

  TodayData? getTodayData() {
    if (aqicn == null) {
      return null;
    }

    var today = _fromAqi(aqicn!.aqi, DateTime.now());
    return TodayData(today.emoji, today.text, today.aqi, today.color, hotspot!,
        aqicn!.iaqi.t.v, aqicn!.iaqi.w.v);
  }

  List<List<HourlyChartData>>? getHourlyData() {
    if (openmeteo == null || aqicn == null) {
      return null;
    }

    List<HourlyChartData> res = [];
    var dailyData = getDailyDatas();
    List factor = List.generate(3, (index) => dailyData![index].aqi / openmeteo!.hourly.us_aqi_pm2_5[index*24]!) ;
    for (var i = 0; i <= 72; i++) {
      if (openmeteo!.hourly.us_aqi_pm2_5[i] == null) {
        break;
      }
      int aqi = 0;
      if(i <= 23){
        aqi = (openmeteo!.hourly.us_aqi_pm2_5[i]! * factor[0]).ceil();
      }else if(i <= 47){
        aqi = (openmeteo!.hourly.us_aqi_pm2_5[i]! * factor[1]).ceil();
      }else{
        aqi = (openmeteo!.hourly.us_aqi_pm2_5[i]! * factor[2]).ceil();
      }
      
      var color = style.aqiColor[0];
      if (aqi <= 50) {
        color = style.aqiColor[0];
      } else if (aqi <= 100) {
        color = style.aqiColor[1];
      } else if (aqi <= 150) {
        color = style.aqiColor[2];
      } else if (aqi <= 200) {
        color = style.aqiColor[3];
      } else if (aqi <= 300) {
        color = style.aqiColor[4];
      } else {
        color = style.aqiColor[5];
      }
      res.add(HourlyChartData(
          DateTime.parse(openmeteo!.hourly.time[i]), aqi, color));
    }
    return [res.sublist(0, 24), res.sublist(24, 48), res.sublist(48, 72)];
  }
}
