import 'package:app/forecast/daily.dart';
import 'package:app/forecast/forecast_data.dart';
import 'package:app/forecast/hourly.dart';
import 'package:app/forecast/today.dart';
import 'package:flutter/material.dart';
import 'package:app/style.dart' as style;
import 'package:intl/intl.dart';

class Forecast extends StatefulWidget {
  final ForecastData data;
  final Future<void> Function() onRefresh;

  const Forecast({super.key, required this.data, required this.onRefresh});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        child: Container(
          margin:
              const EdgeInsets.only(left: 25, top: 20, right: 25, bottom: 20),
          child: Column(
            children: [
              infoCard("Today", Colors.transparent, 200,
                  TodayWidget(data: widget.data)),
              infoCard(
                  "Daily", style.greyUI, 180, DailyWidget(data: widget.data)),
              infoCard(
                  "Hourly", style.greyUI, 260, HourlyWidget(data: widget.data)),
              Center(
                child: Text(
                    "Last update ${DateFormat.Hm().format(widget.data.created)}"),
              )
            ],
          ),
        ),
      ),
    );
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
