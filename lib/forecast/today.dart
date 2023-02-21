import 'package:app/style.dart' as style;
import 'package:app/forecast/forecast_data.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TodayData {
  final String emoji;
  final String text;
  final int aqi;
  final Color color;

  final int hotspot;
  final double temperature;
  final double wind;

  TodayData(this.emoji, this.text, this.aqi, this.color, this.hotspot,
      this.temperature, this.wind);
}


class TodayWidget extends StatefulWidget {
  final ForecastData data;

  const TodayWidget({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => _TodayWidgetState();
}

class _TodayWidgetState extends State<TodayWidget> {
  TodayData? _todayData;

  @override
  Widget build(BuildContext context) {
    _todayData = widget.data.getTodayData();

    if (_todayData == null) {
      return Container(
          decoration: BoxDecoration(
              color: style.greyUI, borderRadius: BorderRadius.circular(15.0)),
          child: Center(
              child: LoadingAnimationWidget.prograssiveDots(
                  color: Colors.white, size: 50)));
    }

    return today(_todayData!);
  }

  Widget today(TodayData todayData) {
    var currColor = todayData.color;
    var darkerOffset = 0.3; // 0.0 - 1.0
    var darkerColor = HSLColor.fromColor(currColor)
        .withLightness((HSLColor.fromColor(currColor).lightness - darkerOffset)
            .clamp(0.0, 1.0))
        .toColor();

    return Container(
      decoration: BoxDecoration(
          color: currColor, borderRadius: BorderRadius.circular(15.0)),
      child: Column(children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  todayData.emoji,
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
                        "AQI ${todayData.aqi}",
                        textScaleFactor: 2.0,
                      ),
                      Text(
                        todayData.text,
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
            decoration: BoxDecoration(
                color: darkerColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0))),
            child: Row(
              children: _todayLower(todayData),
            ),
          ),
        )
      ]),
    );
  }

  List<Widget> _todayLower(TodayData todayData) {
    var temp = todayData.temperature;
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

    var wind = todayData.wind;
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
              "${todayData.hotspot} 🥵",
              textScaleFactor: 1.5,
            ),
            const Text("จุดความร้อน")
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Text(
              "${todayData.wind} Km/h",
              textScaleFactor: 1.5,
            ),
            Text(windStr)
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Text(
              "${todayData.temperature} °C",
              textScaleFactor: 1.5,
            ),
            Text(tempStr)
          ],
        ),
      )
    ];
  }
}
