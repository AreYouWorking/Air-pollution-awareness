import 'package:app/EditPhoto/templates.dart';
import 'package:app/EditPhoto/text_widget.dart';
import 'package:app/EditPhoto/text_widget_icon.dart';
import 'package:flutter/cupertino.dart';

class RecommendationText1 extends StatelessWidget {
  const RecommendationText1(
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
    String text = aqi <= 50 ? 'Enjoy Outdoor Activity' : 'Wear Mask Outdoor';
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: text,
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
    return _getTextBasedOnAqi(aqi);
  }

  Widget _getTextBasedOnAqi(int aqi) {
    if (aqi <= 50) {
      return iconOrNoIcon
          ? TextWidgetIcon(
              text: 'Enjoy Outdoor Activity',
              fontSize: fontSize,
              iconFilePath: 'assets/icons/outdoor_exercise.svg',
              defaultVariation: defaultVariation,
            )
          : TextWidget(
              text: 'Enjoy Outdoor Activity',
              fontSize: fontSize,
              defaultVariation: defaultVariation);
    } else {
      return iconOrNoIcon
          ? TextWidgetIcon(
              text: 'Wear Mask Outdoor',
              fontSize: fontSize,
              iconFilePath: 'assets/icons/uis_head-side-mask.svg',
              defaultVariation: defaultVariation,
            )
          : TextWidget(
              text: 'Wear Mask Outdoor',
              fontSize: fontSize,
              defaultVariation: defaultVariation);
    }
  }
}
