import 'package:app/forecast/forecast_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DailyData {
  Color color;
  String emoji;
  int aqi;
  String text;
  DateTime datetime;

  DailyData(this.color, this.emoji, this.aqi, this.text, this.datetime);
}

class DailyWidget extends StatefulWidget {
  final ForecastData data;

  const DailyWidget({super.key, required this.data});

  @override
  State<DailyWidget> createState() => _DailyWidgetState();
}

class _DailyWidgetState extends State<DailyWidget> {
  List<DailyData>? _dailyData;
  @override
  Widget build(BuildContext context) {
    _dailyData = widget.data.getDailyDatas();
    if (_dailyData == null) {
      return Center(
          child: LoadingAnimationWidget.prograssiveDots(
              color: Colors.white, size: 50));
    }

    List<Widget> dailyCards = [];
    for (var v in _dailyData!) {
      dailyCards.add(_dailyCard(v));
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      children: dailyCards,
    );
  }

  Widget _dailyCard(DailyData data) {
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
                    Text("AQI ${data.aqi}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    Text(data.text , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold) )
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
