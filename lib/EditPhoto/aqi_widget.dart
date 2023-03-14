import 'package:app/EditPhoto/templates.dart';
import 'package:app/EditPhoto/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AqiWidget extends StatelessWidget {
  const AqiWidget(
      {super.key,
      required this.aqi,
      required this.fontSize,
      required this.defaultVariation});

  final int aqi;
  final double fontSize;
  final WidgetVariation defaultVariation;

  Size textSize() {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: "AQI $aqi",
            style: TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                height: 1)),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return TextWidget(
        text: "AQI $aqi",
        fontSize: fontSize,
        defaultVariation: defaultVariation);
  }
}
