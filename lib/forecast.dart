import 'package:app/openmetro/airquality.dart';
import 'package:app/aqicn/geofeed.dart' as aqicn;
import 'package:flutter/material.dart';
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
  DateTime datetime;

  DailyData(this.color, this.emoji, this.aqi, this.text, this.datetime);
}

class ChartData {
  final DateTime x;
  final int y;
  ChartData(this.x, this.y);
}

DailyData fromAqi(int aqi, DateTime datetime) {
  if (aqi <= 50) {
    return DailyData(aqiColor[0], "😍", aqi, "ดีต่อสุขภาพ", datetime);
  } else if (aqi <= 100) {
    return DailyData(aqiColor[1], "😐", aqi, "ปานกลาง", datetime);
  } else if (aqi <= 150) {
    return DailyData(aqiColor[2], "🙁", aqi, "แย่ต่อกลุ่มเสี่ยง", datetime);
  } else if (aqi <= 200) {
    return DailyData(aqiColor[3], "😨", aqi, "แย่ต่อสุขภาพ", datetime);
  } else if (aqi <= 300) {
    return DailyData(aqiColor[4], "😱", aqi, "แย่ต่อสุขภาพมาก", datetime);
  }
  return DailyData(aqiColor[5], "😵", aqi, "อันตรายต่อสุขภาพมาก", datetime);
}

List<DailyData> getDailyData(aqicn.Data data) {
  var now = DateTime.now();
  List<DailyData> result = [fromAqi(data.aqi, now)];
  // following this scale https://aqicn.org/scale/
  for (var v in data.forecast.daily.pm25) {
    var datetime = DateTime.parse(v.day);
    if (datetime.isAfter(now)) {
      result.add(fromAqi(v.avg, datetime));
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
  aqicn.Data? aqicnData;

  Forecast({super.key, this.data, this.aqicnData});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  int hourlyCurrIdx = 0;
  var pressedBtns = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // refetch ?
      },
      child: SingleChildScrollView(
        child: Container(
          margin:
              const EdgeInsets.only(left: 40, top: 20, right: 40, bottom: 20),
          child: Column(
            children: [
              infoCard(
                  "Today", const Color.fromRGBO(255, 77, 0, 1), 200, today()),
              infoCard("Daily", greyUI, 180, daily()),
              infoCard("Hourly", greyUI, 260, hourly()),
            ],
          ),
        ),
      ),
    );
  }

  Widget today() {
    if (widget.aqicnData == null) {
      return Container();
    }

    var aqi = getDailyData(widget.aqicnData!);
    return Column(children: [
      Expanded(
        flex: 3,
        child: Row(
          children: [
            Expanded(
              child: Text(
                aqi[0].emoji,
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
                      "AQI ${aqi[0].aqi}",
                      textScaleFactor: 2.0,
                    ),
                    Text(
                      aqi[0].text,
                      textScaleFactor: 1.5,
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
    if (widget.aqicnData == null) {
      return [Container()];
    }
    var temp = widget.aqicnData!.iaqi.t.v;
    var tempStr = "";
    if (temp < 20) {
      tempStr = "หนาว";
    } else if (temp < 25) {
      tempStr = "อบอุ่น";
    } else if (temp < 27) {
      tempStr = "ร้อน";
    } else {
      tempStr = "ร้อนมาก";
    }

    var wind = widget.aqicnData!.iaqi.w.v;
    var windStr = "";
    if (wind < 5) {
      windStr = "ลมสงบ";
    } else if (wind < 10) {
      windStr = "ลมเล็กน้อย";
    } else if (wind < 15) {
      windStr = "ลมปานกลาง";
    } else {
      windStr = "ลมแรง";
    }
    return [
      Expanded(
        child: Column(
          children: [
            Text(
              "5 🥵",
              textScaleFactor: 1.5,
            ),
            Text("จุดความร้อน")
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Text(
              "${widget.aqicnData!.iaqi.w.v} Km/h",
              textScaleFactor: 1.5,
            ),
            Text("$windStr")
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Text(
              "${widget.aqicnData!.iaqi.t.v} °C",
              textScaleFactor: 1.5,
            ),
            Text('$tempStr')
          ],
        ),
      )
    ];
  }

  Widget daily() {
    if (widget.aqicnData == null) {
      return Container();
    }
    var aqi = getDailyData(widget.aqicnData!);
    List<Widget> dailyCards = [];
    for (var v in aqi) {
      dailyCards.add(dailyCard(v));
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      children: dailyCards,
    );
  }

  Widget dailyCard(DailyData data) {
    final now = DateTime.now();
    Text day = const Text("Today");

    if (data.datetime.isAfter(now)) {
      day = Text(DateFormat.EEEE().format(data.datetime));
    }
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          day,
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: data.color, borderRadius: BorderRadius.circular(10.0)),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              hourlyButton(0, "Today"),
              hourlyButton(1, DateFormat.EEEE().format(nextDay)),
              hourlyButton(2, DateFormat.EEEE().format(next2Day)),
            ],
          ),
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
        style: pressedBtns[idx]
            ? TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: const StadiumBorder(
                    side: BorderSide(width: 2.0, color: Colors.white)),
              )
            : TextButton.styleFrom(foregroundColor: Colors.white),
        onPressed: () {
          setState(() {
            hourlyCurrIdx = idx;
            pressedBtns.setAll(0, [false, false, false]);
            pressedBtns[idx] = !pressedBtns[idx];
          });
        },
        child: Text(text));
  }

  Container infoCard(String text, Color color, double height, Widget info) {
    return Container(
      height: height,
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
