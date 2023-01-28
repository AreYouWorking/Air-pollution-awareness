import 'package:flutter/widgets.dart';

const greyUI = Color.fromRGBO(28, 28, 30, 1);

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 20),
      child: Column(
        children: <Widget>[
          todayWidget(),
          dailyWidget(),
          hourlyWidget(),
        ],
      ),
    );
  }

  Column hourlyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hourly',
          textScaleFactor: 1.3,
        ),
        Container(
          decoration: BoxDecoration(
              color: greyUI, borderRadius: BorderRadius.circular(15.0)),
          height: 200,
          width: 320,
        )
      ],
    );
  }

  Container dailyWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily',
            textScaleFactor: 1.3,
          ),
          Container(
            decoration: BoxDecoration(
                color: greyUI, borderRadius: BorderRadius.circular(15.0)),
            height: 175,
            width: 320,
          )
        ],
      ),
    );
  }

  Container todayWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today',
            textScaleFactor: 1.3,
          ),
          Container(
            decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 77, 0, 1),
                borderRadius: BorderRadius.circular(15.0)),
            height: 200,
            width: 320,
          )
        ],
      ),
    );
  }
}
