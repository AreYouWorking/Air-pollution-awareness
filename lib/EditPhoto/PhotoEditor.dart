import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app/EditPhoto/aqi_widget.dart';
import 'package:app/EditPhoto/aqi_widget_emoji.dart';
import 'package:app/EditPhoto/recommendation_text1.dart';
import 'package:app/EditPhoto/recommendation_text2.dart';
import 'package:app/EditPhoto/templates.dart';
import 'package:app/EditPhoto/text_widget.dart';
import 'package:app/EditPhoto/text_widget_icon.dart';
import 'package:app/api/aqicn/geofeed.dart';
import 'package:app/forecast/hotspot.dart';
import 'package:app/location/selectlocation.dart';
import 'package:app/location/userposition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

class OverlaidWidget {
  Offset position = Offset(0.1, 0.1);
  double scale = 1.0;
  double rotation = 0.0;
  Widget? widget;
}

class PhotoEditor extends StatefulWidget {
  const PhotoEditor({super.key, required this.image});

  final File image;

  @override
  State<StatefulWidget> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  List<List<OverlaidWidget>>? _templates;

  Future<Color>? _dominantColorFuture;
  Size? _editingAreaSize;
  double? _aspectRatio;

  bool _isTemplateChangeAllowed = true;
  bool _hideMenu = false;
  bool _hideDelete = true;
  bool _nearDelete = false;

  final GlobalKey _globalKey = GlobalKey();

  final PageController _pageController = PageController(initialPage: 999);

  final DraggableScrollableController slideUpPanelController =
      DraggableScrollableController();
  final minSlideUpPanelSize = 0.0;
  final midSlideUpPanelSize = 0.6;
  final maxSlideUpPanelSize = 1.0;
  static const int slideUpAnimationDurationInMs = 300;

  int? _aqi;
  int _hotspot = 0;
  String? _placeName;

  OverlaidWidget? _activeItem;
  late Offset _initPos;
  late Offset _currentPos;
  late double _currentScale;
  late double _currentRotation;
  bool? _inAction;

  bool _isSaving = false;

  Future<Color>? _getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor!.color;
  }

  void _initTemplate() async {
    var decodedImage =
        await decodeImageFromList(widget.image.readAsBytesSync());
    if (!mounted) return;
    double aspectRatio = decodedImage.width / decodedImage.height;
    double editingAreaWidth = MediaQuery.of(context).size.width;
    double editingAreaHeight = min(editingAreaWidth * (1 / aspectRatio),
        MediaQuery.of(context).size.height);

    setState(() {
      _aspectRatio = aspectRatio;
      _editingAreaSize = Size(editingAreaWidth, editingAreaHeight);
    });
    _fetchData();
  }

  void _fetchData() async {
    showLoaderDialog(context);
    Data aqicn = await getData(
        Userposition.latitudeChosen, Userposition.longitudeChosen);

    int hotspot = await searchHotspot();
    setState(() {
      _templates = buildTemplates(aqicn.aqi, Userposition.display_place_Chosen,
          hotspot, _editingAreaSize!);
      _hotspot = hotspot;
      _aqi = aqicn.aqi;
      _placeName = Userposition.display_place_Chosen;
    });
    if (mounted) Navigator.pop(context);
  }

  Future<File> _savePicture() async {
    Fluttertoast.showToast(
        msg: "Saved to Gallery",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
    setState(() {
      _isSaving = true;
    });
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final directory = (await getApplicationDocumentsDirectory()).path;
    // print(directory); // directory = /data/user/0/com.example.app/app_flutter
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    File imgFile = File('$directory/${timestamp()}.png');
    imgFile.writeAsBytes(pngBytes!);
    // print(imgFile.path);
    await Future.delayed(const Duration(
        milliseconds: 500)); // waiting for image fully writeAsBytes
    await GallerySaver.saveImage(imgFile.path,
        toDcim: true, albumName: 'AirWareness');
    setState(() {
      _isSaving = false;
    });

    return imgFile;
  }

  void _sharePicture() async {
    File imgFile = await _savePicture();
    await Share.shareXFiles([XFile(imgFile.path)]);
    await imgFile.delete();
  }

  @override
  void initState() {
    _dominantColorFuture = _getImagePalette(FileImage(widget.image));
    _initTemplate();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // https://www.youtube.com/watch?v=PTyvarfJiW8
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final editingArea = _editingAreaSize;
    final photoAspectRatio = _aspectRatio;
    final templates = _templates;
    final aqi = _aqi;
    final placeName = _placeName;

    if (editingArea == null || aqi == null || placeName == null) {
      return Container();
    }

    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: <Widget>[
          // Photo Editing area
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _animateHidePanel();
              },
              onScaleStart: (details) {
                _initPos = details.focalPoint;
                if (_activeItem == null) return;

                _currentPos = _activeItem!.position;
                _currentScale = _activeItem!.scale;
                _currentRotation = _activeItem!.rotation;
                setState(() {
                  _hideMenu = true;
                  _hideDelete = false;
                });
              },
              onScaleUpdate: (details) {
                final delta = details.focalPoint - _initPos;
                if (_activeItem == null) {
                  if (delta.dy < -5) {
                    _animateShowPanel();
                  }
                  return;
                }
                final left = (delta.dx / editingArea.width) + _currentPos.dx;
                final top = (delta.dy / editingArea.height) + _currentPos.dy;

                setState(() {
                  _activeItem!.position = Offset(left, top);
                  _activeItem!.rotation = details.rotation + _currentRotation;
                  _activeItem!.scale = details.scale * _currentScale;
                  _hideMenu = true;

                  final dx = details.focalPoint.dx;
                  final dy = details.focalPoint.dy;

                  // If picture size is big, the delete button is shown
                  // overlaying on top of picture, else the button is on the
                  // black bar.
                  if (screenSize.height - 50 <
                      screenSize.height / 2 + editingArea.height / 2) {
                    // It would be more natural to delete the widget, if the
                    // widget is dragged to the center, touching the delete
                    // button.
                    if (dx >= screenSize.width * 0.25 &&
                        dx <= screenSize.width * 0.75 &&
                        dy > screenSize.height - 50) {
                      _nearDelete = true;
                      return;
                    }
                  } else {
                    // The delete button is on the black bar, just drag to the
                    // black bar, then that widget is deleted.
                    if (dy > screenSize.height / 2 + editingArea.height / 2) {
                      _nearDelete = true;
                      return;
                    }
                  }
                  _nearDelete = false;
                });
              },
              child: Align(
                alignment: (() {
                  if (photoAspectRatio != null) {
                    if ((photoAspectRatio - 9 / 16).abs() < 0.1) {
                      return AlignmentDirectional.topCenter;
                    }
                  }

                  return AlignmentDirectional.center;
                }()),
                child: SizedBox(
                    width: editingArea.width,
                    height: editingArea.height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: RepaintBoundary(
                          key: _globalKey,
                          child: Stack(clipBehavior: Clip.antiAlias, children: <
                              Widget>[
                            FutureBuilder<Color>(
                                future: _dominantColorFuture,
                                builder: (BuildContext context,
                                    AsyncSnapshot<Color> snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(color: snapshot.data);
                                  } else {
                                    return Container(color: Colors.black);
                                  }
                                }),
                            Transform.scale(
                                // TODO: Implement Zoom
                                scale: 1,
                                child: Center(child: Image.file(widget.image))),
                            NotificationListener<ScrollNotification>(
                              onNotification: (scrollNotification) {
                                if (scrollNotification
                                    is ScrollStartNotification) {
                                  setState(() {
                                    _hideMenu = true;
                                  });
                                } else if (scrollNotification
                                    is ScrollEndNotification) {
                                  setState(() {
                                    _hideMenu = false;
                                  });
                                }
                                return true;
                              },
                              child: PageView.builder(
                                key: Key('$aqi$_placeName'),
                                controller: _pageController,
                                scrollDirection: Axis.horizontal,
                                physics: _isTemplateChangeAllowed == true
                                    ? const AlwaysScrollableScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return Stack(
                                    children: templates == null
                                        ? []
                                        : templates[index % templates.length]
                                            .map(_buildItemWidget)
                                            .toList(),
                                  );
                                },
                              ),
                            )
                          ])),
                    )),
              )),
          _hideMenu ? Container() : _getTopMenu(),
          _hideDelete ? Container() : _getDeleteButton(),
          _getAddWidgetMenu(aqi, placeName)
        ]));
  }

  void _animateShowPanel() {
    if (_templates == null) return;
    slideUpPanelController.animateTo(midSlideUpPanelSize,
        duration: const Duration(milliseconds: slideUpAnimationDurationInMs),
        curve: Curves.easeIn);
  }

  void _animateHidePanel() {
    slideUpPanelController.animateTo(minSlideUpPanelSize,
        duration: const Duration(milliseconds: slideUpAnimationDurationInMs),
        curve: Curves.easeOut);
  }

  void _addOverlaidWidget(Widget widgetToAdd) {
    int currPage = _pageController.page!.toInt() % _templates!.length;
    OverlaidWidget overlaidWidget = OverlaidWidget()
      ..widget = widgetToAdd
      ..position = const Offset(0.2, 0.2);
    setState(() {
      _templates![currPage].add(overlaidWidget);
    });
  }

// https://stackoverflow.com/questions/51415236/show-circular-progress-dialog-in-login-screen-in-flutter-how-to-implement-progr
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 24),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () async => true, child: alert);
      },
    );
  }

  Widget _getAddWidgetMenu(int aqi, String placeName) {
    return DraggableScrollableSheet(
        initialChildSize: minSlideUpPanelSize,
        minChildSize: minSlideUpPanelSize,
        snap: true,
        snapSizes: [midSlideUpPanelSize],
        snapAnimationDuration:
            const Duration(milliseconds: slideUpAnimationDurationInMs),
        controller: slideUpPanelController,
        builder: (context, scrollController) {
          return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: const Color.fromRGBO(0, 0, 0, 0.8),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      itemExtent: 120.0,
                      controller: scrollController,
                      key: Key('$aqi$_placeName'),
                      children: <Widget>[
                        AqiWidget(
                            aqi: aqi,
                            fontSize: 64,
                            defaultVariation: WidgetVariation.whiteNoBg),
                        AqiWidgetEmoji(
                            aqi: aqi,
                            fontSize: 64,
                            defaultVariation: WidgetVariation.whiteNoBg),
                        TextWidget(
                            text: '$_hotspot hot spots near me',
                            fontSize: 36,
                            defaultVariation: WidgetVariation.whiteNoBg),
                        TextWidgetIcon(
                            text: placeName,
                            fontSize: 36,
                            iconFilePath:
                                'assets/icons/near_me_FILL1_wght400_GRAD0_opsz48.svg',
                            defaultVariation: WidgetVariation.whiteNoBg),
                        RecommendationText1(
                          aqi: aqi,
                          fontSize: 36,
                          defaultVariation: WidgetVariation.whiteNoBg,
                          iconOrNoIcon: false,
                        ),
                        RecommendationText2(
                          aqi: aqi,
                          fontSize: 36,
                          defaultVariation: WidgetVariation.whiteNoBg,
                          iconOrNoIcon: false,
                        ),
                        RecommendationText1(
                          aqi: aqi,
                          fontSize: 36,
                          defaultVariation: WidgetVariation.whiteNoBg,
                          iconOrNoIcon: true,
                        ),
                        RecommendationText2(
                          aqi: aqi,
                          fontSize: 36,
                          defaultVariation: WidgetVariation.whiteNoBg,
                          iconOrNoIcon: true,
                        )
                      ].map(_buildWidgetPreviewTile).toList(),
                    ),
                  ),
                ],
              ));
        });
  }

  Widget _getDeleteButton() {
    return Align(
        alignment: AlignmentDirectional.bottomCenter,
        child: Container(
            padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 24.0),
            child:
                // Go back
                _circularButton(() {
              // TODO: show confirm dialog before going back
              if (!mounted) return;
              print("inside");
              Navigator.pop(context);
            },
                    const Color(0x64000000),
                    Icon(
                      Icons.delete,
                      size: 28,
                      color: _nearDelete ? Colors.red : Colors.white,
                    ))));
  }

  Widget _getTopMenu() {
    return Align(
        alignment: AlignmentDirectional.topCenter,
        child: Container(
            padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 24.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Go back
                  _circularButton(() {
                    // TODO: show confirm dialog before going back
                    if (!mounted) return;
                    Navigator.pop(context);
                  }, const Color(0x64000000),
                      const Icon(Icons.arrow_back_ios_new, size: 28)),
                  Wrap(
                      spacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        // Change location
                        _circularButton(() async {
                          if (!mounted) return;
                          final chosenLocation = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Selectlocation(
                                      predefinedLocation: [],
                                    )),
                          );
                          if (chosenLocation != null) {
                            setState(() {
                              Userposition.setChosenLocation(
                                  chosenLocation.lat.toString(),
                                  chosenLocation.lon.toString(),
                                  chosenLocation.name);
                            });
                            _fetchData();
                          }
                        },
                            const Color(0x64000000),
                            const Icon(Icons.edit_location_alt_outlined,
                                size: 32)),
                        // Add widget
                        _circularButton(
                            _animateShowPanel,
                            const Color(0x64000000),
                            const Icon(Icons.sticky_note_2_outlined, size: 32)),
                        // Share
                        _circularButton(_sharePicture, const Color(0x64000000),
                            const Icon(Icons.ios_share, size: 32)),
                        // Save
                        _circularButton(
                            !_isSaving ? _savePicture : null,
                            const Color(0x64000000),
                            const Icon(Icons.save_alt, size: 32)),
                      ]),
                ])));
  }

  Widget _circularButton(
    void Function()? onPressed,
    Color buttonColor,
    Widget icon,
  ) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          backgroundColor: buttonColor,
          // <-- Button color
          foregroundColor: Colors.white, // <-- Splash color
        ),
        child: icon);
  }

  Widget _buildWidgetPreviewTile(Widget previewWidget) {
    return Center(
      child: InkResponse(
          onTap: () {
            _animateHidePanel();
            _addOverlaidWidget(previewWidget);
          },
          child: IgnorePointer(child: previewWidget)),
    );
  }

  Widget _buildItemWidget(OverlaidWidget e) {
    ui.Size? sz = _editingAreaSize;
    if (sz == null) {
      return Container();
    }

    return Positioned(
      top: e.position.dy * sz.height,
      left: e.position.dx * sz.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(
          angle: e.rotation,
          child: Listener(
            onPointerDown: (details) {
              if (_inAction == null) return;
              if (_inAction == true) return;
              _inAction = true;
              _activeItem = e;
              _initPos = details.position;
              _currentPos = e.position;
              _currentScale = e.scale;
              _currentRotation = e.rotation;

              setState(() {
                _isTemplateChangeAllowed = false;
              });
            },
            onPointerUp: (details) {
              _inAction = false;
              setState(() {
                _isTemplateChangeAllowed = true;
                _hideMenu = false;
                _hideDelete = true;
              });
              print(details);
              print(details.position.dx);
              print(details.position.dy);
              if (_nearDelete) {
                _activeItem?.position = Offset(200, 800);
                Vibration.vibrate(duration: 100);
              }
              _activeItem = null;
            },
            child: e.widget,
          ),
        ),
      ),
    );
  }
}
