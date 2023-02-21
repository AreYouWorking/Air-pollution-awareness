import 'package:app/forecast/forecast_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HourlyChartData {
  final DateTime x;
  final int y;
  final Color color;
  HourlyChartData(this.x, this.y, this.color);
}

class HourlyWidget extends StatefulWidget {
  final ForecastData data;
  const HourlyWidget({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => _HourlyWidgetState();
}

class _HourlyWidgetState extends State<HourlyWidget> {
  List<List<HourlyChartData>>? _hourlyData;
  int hourlyCurrIdx = 0;
  List<bool> pressedBtns = [true, false, false];

  @override
  Widget build(BuildContext context) {
    _hourlyData = widget.data.getHourlyData();
    if (_hourlyData == null) {
      return Center(
          child: LoadingAnimationWidget.prograssiveDots(
              color: Colors.white, size: 50));
    }

    return hourly(_hourlyData!);
  }

  Widget hourly(List<List<HourlyChartData>> data) {
    final now = DateTime.now();
    final nextDay = now.add(const Duration(days: 1));
    final next2Day = now.add(const Duration(days: 2));

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
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(dateFormat: DateFormat.H(), interval: 1),
            primaryYAxis: NumericAxis(minimum: 0),
            series: <ChartSeries<HourlyChartData, DateTime>>[
              ColumnSeries<HourlyChartData, DateTime>(
                  dataSource: data[hourlyCurrIdx],
                  pointColorMapper: (HourlyChartData data, _) => data.color,
                  xValueMapper: (HourlyChartData data, _) => data.x,
                  yValueMapper: (HourlyChartData data, _) => data.y),
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
}
