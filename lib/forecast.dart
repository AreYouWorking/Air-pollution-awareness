import 'package:app/openmetro/airquality.dart';
import 'package:app/aqicn/geofeed.dart' as aqicn;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as chart;

const greyUI = Color.fromRGBO(28, 28, 30, 1);
const aqiColor = [
  Color.fromRGBO(55, 146, 55, 1),
  Color.fromARGB(255, 198, 198, 0),
  Color.fromARGB(255, 212, 180, 73),
  Color.fromARGB(255, 232, 108, 108),
  Color.fromARGB(255, 156, 29, 29),
  Color.fromRGBO(128, 55, 146, 1)
];

class DailyData {
  Color color;
  String emoji;
  int aqi;
  String text;

  DailyData(this.color, this.emoji, this.aqi, this.text);
}

class ChartData {
  final DateTime x;
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
  // follwing this scale https://aqicn.org/scale/
  for (var aqi in aqis) {
    if (aqi <= 50) {
      result.add(DailyData(aqiColor[0], "😀", aqi, "Good"));
    } else if (aqi <= 100) {
      result.add(DailyData(aqiColor[1], "🙂", aqi, "Moderate"));
    } else if (aqi <= 150) {
      result.add(DailyData(aqiColor[2], "😷", aqi, "Unhealthy for SG"));
    } else if (aqi <= 200) {
      result.add(DailyData(aqiColor[3], "😷", aqi, "Unhealthy"));
    } else if (aqi <= 300) {
      result.add(DailyData(aqiColor[4], "😵", aqi, "Very Unhealthy"));
    } else {
      result.add(DailyData(aqiColor[5], "😡", aqi, "Hazardous"));
    }
  }

  return result;
}

List<List<ChartData>> getHourlyData(Airquality data) {
  List<ChartData> res = [];
  for (var i = 0; i <= 72; i++) {
    if (data.hourly.us_aqi_pm2_5[i] == null) {
      break;
    }
    res.add(ChartData(
        DateTime.parse(data.hourly.time[i]), data.hourly.us_aqi_pm2_5[i]!));
  }
  return [res.sublist(0, 24), res.sublist(25, 48), res.sublist(49, res.length)];
}

class Forecast extends StatefulWidget {
  Airquality? data;
  List<DailyData>? aqi;
  aqicn.Iaqi? iaqi;

  Forecast({super.key, this.data, this.aqi, this.iaqi});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  int hourlyCurrIdx = 0;

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
    if (widget.aqi == null) {
      return Container();
    }

    return Column(children: [
      Expanded(
        flex: 3,
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.aqi![0].emoji,
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
                      "AQI ${widget.aqi![0].aqi}",
                      textScaleFactor: 2.0,
                    ),
                    Text(
                      widget.aqi![0].text,
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
    if (widget.iaqi == null) {
      return [Container()];
    }

    return [
      Expanded(
        child: Column(
          children: [
            Text(
              "5 🥵",
              textScaleFactor: 1.5,
            ),
            Text("Hotspot")
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Text(
              "${widget.iaqi!.w.v} Km/h",
              textScaleFactor: 1.5,
            ),
            Text("Not Windy")
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Text(
              "${widget.iaqi!.t.v} °C",
              textScaleFactor: 1.5,
            ),
            Text("Hot")
          ],
        ),
      )
    ];
  }

  Widget daily() {
    if (widget.aqi == null) {
      return Container();
    }
    final now = DateTime.now();
    final nextDay = now.add(const Duration(days: 1));
    final next2Day = now.add(const Duration(days: 2));
    return Row(
      children: [
        dailyCard(widget.aqi![0], "Today"),
        dailyCard(widget.aqi![1], DateFormat.EEEE().format(nextDay)),
        dailyCard(widget.aqi![2], DateFormat.EEEE().format(next2Day))
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.emoji,
                        textScaleFactor: 1.4,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
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

  Widget hourly() {
    if (widget.data == null) {
      return Container();
    }

    final now = DateTime.now();
    final nextDay = now.add(const Duration(days: 1));
    final next2Day = now.add(const Duration(days: 2));
    var datasrc = getHourlyData(widget.data!);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            hourlyButton(0, "Today"),
            hourlyButton(1, DateFormat.EEEE().format(nextDay)),
            hourlyButton(2, DateFormat.EEEE().format(next2Day)),
          ],
        ),
        Expanded(
          child: chart.SfCartesianChart(
            primaryXAxis: chart.DateTimeAxis(
              dateFormat: DateFormat.H(),
            ),
            series: <chart.ChartSeries<ChartData, DateTime>>[
              chart.ColumnSeries<ChartData, DateTime>(
                  onCreateRenderer:
                      (chart.ChartSeries<ChartData, DateTime> series) {
                    return _CustomColumnSeriesRenderer();
                  },
                  dataSource: datasrc[hourlyCurrIdx],
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y),
            ],
          ),
        ),
      ],
    );
  }

  Widget hourlyButton(int idx, String text) {
    return TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: const StadiumBorder(side: BorderSide(width: 2.0, color: Colors.white)),
        ),
        onPressed: () {
          setState(() {
            hourlyCurrIdx = idx;
          });
        },
        child: Text(text));
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

class _CustomColumnSeriesRenderer extends chart.ColumnSeriesRenderer {
  _CustomColumnSeriesRenderer();

  @override
  chart.ChartSegment createSegment() {
    return _ColumnCustomPainter();
  }
}

class _ColumnCustomPainter extends chart.ColumnSegment {
  @override
  Paint getFillPaint() {
    final Paint customerFillPaint = Paint();
    customerFillPaint.isAntiAlias = false;

    var aqi = segmentRect.height;
    if (aqi <= 50) {
      customerFillPaint.color = aqiColor[0];
    } else if (aqi <= 100) {
      customerFillPaint.color = aqiColor[1];
    } else if (aqi <= 150) {
      customerFillPaint.color = aqiColor[2];
    } else if (aqi <= 200) {
      customerFillPaint.color = aqiColor[3];
    } else if (aqi <= 300) {
      customerFillPaint.color = aqiColor[4];
    } else {
      customerFillPaint.color = aqiColor[5];
    }
    customerFillPaint.style = PaintingStyle.fill;
    return customerFillPaint;
  }
}
