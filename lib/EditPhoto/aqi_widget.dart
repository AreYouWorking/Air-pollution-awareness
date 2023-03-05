import 'package:app/EditPhoto/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AqiWidget extends StatelessWidget {
  const AqiWidget(
      {super.key, required this.aqi, required this.defaultVariation});

  final int aqi;
  final int defaultVariation;

  @override
  Widget build(BuildContext context) {
    return TextWidget(
        text: "AQI $aqi", fontSize: 64.0, defaultVariation: defaultVariation);
  }
}
