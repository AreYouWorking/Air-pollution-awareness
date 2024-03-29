import 'package:app/EditPhoto/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AqiWidgetEmoji extends StatefulWidget {
  const AqiWidgetEmoji(
      {super.key,
      required this.aqi,
      required this.fontSize,
      required this.defaultVariation});

  final int aqi;
  final double fontSize;
  final WidgetVariation defaultVariation;

  @override
  State<AqiWidgetEmoji> createState() => _AqiWidgetEmojiState();
}

class _AqiWidgetEmojiState extends State<AqiWidgetEmoji> {
  int _tapCount = 0;
  final EdgeInsets _padding = const EdgeInsets.fromLTRB(12, 16, 12, 12);

  List<Widget> _variations = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _variations = [whiteNoBg(), blackNoBg(), whiteBg(), blackBg()];
      _tapCount = widget.defaultVariation.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _tapCount = (_tapCount + 1) % _variations.length;
        });
      },
      child: _variations[_tapCount],
    );
  }

  Widget whiteNoBg() {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
            text: "AQI ${widget.aqi}",
            style: TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w700,
              fontSize: widget.fontSize,
              color: Colors.white,
              height: 1,
            )),
        WidgetSpan(
            child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SvgPicture.asset(
            _getEmoji(widget.aqi),
            width: widget.fontSize,
            height: widget.fontSize,
          ),
        )),
      ],
    ));
  }

  Widget blackNoBg() {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
            text: "AQI ${widget.aqi}",
            style: TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w700,
              fontSize: widget.fontSize,
              color: Colors.black,
              height: 1,
            )),
        WidgetSpan(
            child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SvgPicture.asset(
            _getEmoji(widget.aqi),
            width: widget.fontSize,
            height: widget.fontSize,
          ),
        )),
      ],
    ));
  }

  Widget whiteBg() {
    return Container(
        padding: _padding,
        decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            borderRadius: BorderRadius.circular(15.0)),
        child: whiteNoBg());
  }

  Widget blackBg() {
    return Container(
        padding: _padding,
        decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.5),
            borderRadius: BorderRadius.circular(15.0)),
        child: blackNoBg());
  }

  String _getEmoji(int aqi) {
    if (aqi <= 50) {
      return 'assets/icons/Good_Emoji.svg';
    } else if (aqi <= 100) {
      return 'assets/icons/Moderate_Emoji.svg';
    } else if (aqi <= 150) {
      return 'assets/icons/USG_Emoji.svg';
    } else if (aqi <= 200) {
      return 'assets/icons/Unhealthy_Emoji.svg';
    } else if (aqi <= 300) {
      return 'assets/icons/Very_Unhealthy_Emoji.svg';
    } else {
      return 'assets/icons/Hazardous_Emoji.svg';
    }
  }
}
