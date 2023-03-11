import 'package:app/EditPhoto/templates.dart';
import 'package:app/EditPhoto/text_widget.dart';
import 'package:app/EditPhoto/text_widget_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationText2 extends StatelessWidget {
  const RecommendationText2(
      {super.key,
      required this.aqi,
      required this.fontSize,
      required this.defaultVariation,
      required this.iconOrNoIcon});

  final int aqi;
  final double fontSize;
  final WidgetVariation defaultVariation;
  final bool iconOrNoIcon;

  Size textSize() {
    String text = aqi <= 50 ? 'Fresh air' : 'Avoid Outdoor Exercise';
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: GoogleFonts.oswald(
                fontWeight: FontWeight.w700, fontSize: fontSize, height: 1)),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return _getTextBasedOnAqi(aqi);
  }

  Widget _getTextBasedOnAqi(int aqi) {
    if (aqi <= 50) {
      return iconOrNoIcon
          ? TextWidgetIcon(
              text: 'Fresh air',
              fontSize: fontSize,
              iconFilePath: 'assets/icons/air-rounded.svg',
              defaultVariation: defaultVariation,
            )
          : TextWidget(
              text: 'Fresh Air',
              fontSize: fontSize,
              defaultVariation: defaultVariation);
    } else {
      return iconOrNoIcon
          ? TextWidgetIcon(
              text: 'Avoid Outdoor Exercise',
              fontSize: fontSize,
              iconFilePath: 'assets/icons/material-symbols_exercise.svg',
              defaultVariation: defaultVariation,
            )
          : TextWidget(
              text: 'Avoid Outdoor Exercise',
              fontSize: fontSize,
              defaultVariation: defaultVariation);
    }
  }
}
