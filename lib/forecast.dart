
import 'package:app/openmetro/airquality.dart';
import 'package:app/aqicn/geofeed.dart' as aqicn;
import 'package:app/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as chart;

const greyUI = Color.fromRGBO(28, 28, 30, 1);

class DailyData {
  Color color;
  String emoji;
  int aqi;
  String text;

  DailyData(this.color, this.emoji, this.aqi, this.text);
}

class ChartData {
  final int x;
  final int y;
  ChartData(this.x, this.y);
}

// maybe we can use tuple instead of List ?
List<DailyData> getDailyData(aqicn.Data data) {
  List<int> aqis = [data.aqi];
  var now = DateTime.now();
  var i = 0;
  for (var v in data.forecast.daily.pm25) {
    if (i > 1) break;
    if (DateTime.parse(v.day).isAfter(now)) {
      aqis.add(v.avg);
      i += 1;
    }
  }

  List<DailyData> result = [];
  for (var aqi in aqis) {
    if (aqi < 12) {
      result.add(
          DailyData(const Color.fromRGBO(55, 146, 55, 1), "😀", aqi, "Good"));
    } else if (aqi < 36) {
      result.add(DailyData(
          const Color.fromARGB(255, 240, 255, 157), "🙂", aqi, "Moderate"));
    } else if (aqi < 56) {
      result.add(DailyData(const Color.fromARGB(255, 212, 180, 73), "😷", aqi,
          "Unhealthy for SG"));
    } else if (aqi < 151) {
      result.add(DailyData(
          const Color.fromARGB(255, 232, 108, 108), "😷", aqi, "Unhealthy"));
    } else if (aqi < 251) {
      result.add(DailyData(
          const Color.fromARGB(255, 156, 29, 29), "😵", aqi, "Very Unhealthy"));
    } else {
      result.add(DailyData(
          const Color.fromRGBO(128, 55, 146, 1), "😡", aqi, "Hazardous"));
    }
  }

  return result;
}

List<ChartData> getHourlyData(Airquality data) {
  // TODO: make this receive non-null data, and guarantee some constrains on it
  if (data.hourly.us_aqi_pm2_5.length < 48) {
    throw Exception('data is shorter than expected (48)');
  }

  List<ChartData> res = [];
  for (var i = 0; i <= 48; i++) {
    res.add(ChartData(DateTime.parse(data.hourly.time[i]).hour,
        data.hourly.us_aqi_pm2_5[i]!));
  }
  return res;
}

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  Airquality? data;
  List<DailyData>? aqi;
  aqicn.Iaqi? iaqi;

  Future<void> _initData() async {
    try {
      // TODO: we get user GPS again, maybe there are ways to pass GPS from main to this widget
      // also maybe we can use background service to do all this?
      Position v = await getCurrentLocation();
      var lat = "${v.latitude}";
      var long = "${v.longitude}";
      data = await getAirQuality5day(lat, long);
      var aqicnData = await aqicn.getData(lat, long);
      aqi = getDailyData(aqicnData);
      iaqi = aqicnData.iaqi;
      setState(() {});
    } catch (_) {
      // TODO: do something if can't fetch gps location
    }
  }

  @override
  void initState() {
    super.initState();
    _initData().whenComplete(() => null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 20, right: 40, bottom: 20),
      child: Column(
        children: <Widget>[
          Expanded(
              child: infoCard(
                  "Today", const Color.fromRGBO(255, 77, 0, 1), today())),
          Expanded(child: infoCard("Daily", greyUI, daily())),
          Expanded(child: infoCard("Hourly", greyUI, hourly())),
        ],
      ),
    );
  }

  Widget today() {
    if (aqi == null) {
      return Container();
    }

    return Column(children: [
      Expanded(
        flex: 3,
        child: Row(
          children: [
            Expanded(
              child: Text(
                aqi![0].emoji,
                textScaleFactor: 3.0,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
                  children: [
                    Text(
                      "AQI ${aqi![0].aqi}",
                      textScaleFactor: 2.0,
                    ),
                    Text(
                      aqi![0].text,
                      textScaleFactor: 2.0,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.only(top: 15),
          decoration: const BoxDecoration(
              color: Color.fromRGBO(135, 57, 0, 1),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0))),
          child: Row(
            children: todayLower(),
          ),
        ),
      )
    ]);
  }

  List<Widget> todayLower() {
    if (iaqi == null) {
      return [Container()];
    }

    return [
      Expanded(
        child: Column(
          children: [Text("5 🥵", textScaleFactor: 1.5,), Text("Hotspot")],
        ),
      ),
      Expanded(
        child: Column(
          children: [Text("${iaqi!.w.v} Km/h", textScaleFactor: 1.5,), Text("Not Windy")],
        ),
      ),
      Expanded(
        child: Column(
          children: [Text("${iaqi!.t.v} °C", textScaleFactor: 1.5,), Text("Hot")],
        ),
      )
    ];
  }

  Widget daily() {
    if (aqi == null) {
      return Container();
    }
    final now = DateTime.now();
    final nextDay = now.add(const Duration(days: 1));
    final next2Day = now.add(const Duration(days: 2));
    return Row(
      children: [
        dailyCard(aqi![0], "Today"),
        dailyCard(aqi![1], DateFormat.EEEE().format(nextDay)),
        dailyCard(aqi![2], DateFormat.EEEE().format(next2Day))
      ],
    );
  }

  Expanded dailyCard(DailyData data, String day) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(day),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: data.color,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(children: [
                  Text(data.emoji),
                  Text("AQI ${data.aqi}"),
                  Text(data.text)
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container hourly() {
    if (data == null) {
      return Container();
    }

    var datasrc = getHourlyData(data!);
    return Container(
      child: chart.SfCartesianChart(
        series: <chart.ChartSeries<ChartData, int>>[
          chart.ColumnSeries<ChartData, int>(
              dataSource: datasrc,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y),
        ],
      ),
    );
  }

  Container infoCard(String text, Color color, Widget info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            textScaleFactor: 1.3,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(15.0)),
              child: info,
            ),
          )
        ],
      ),
    );
  }
}
