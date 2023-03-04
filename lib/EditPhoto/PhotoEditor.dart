import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:palette_generator/palette_generator.dart';

class PhotoEditor extends StatefulWidget {
  const PhotoEditor({super.key, required this.image});

  final File image;

  @override
  State<StatefulWidget> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  Future<Color>? _dominantColorFuture;
  Size? _editingAreaSize;
  double? _aspectRatio;

  final GlobalKey _globalKey = GlobalKey();

  OverlaidWidget? _activeItem;

  late Offset _initPos;

  late Offset _currentPos;

  late double _currentScale;

  late double _currentRotation;

  late bool _inAction;

  bool _isSaving = false;

  Future<Color>? _getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor!.color;
  }

  void _setEditingAreaSize() async {
    var decodedImage =
        await decodeImageFromList(widget.image.readAsBytesSync());
    if (!mounted) return;
    double aspectRatio = decodedImage.width / decodedImage.height;
    double editingAreaWidth = MediaQuery.of(context).size.width;
    double editingAreaHeight = editingAreaWidth * (1 / aspectRatio);
    setState(() {
      _aspectRatio = aspectRatio;
      _editingAreaSize = Size(editingAreaWidth, editingAreaHeight);
    });
  }

  Future<void> _savePicture() async {
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
  }

  @override
  void initState() {
    _dominantColorFuture = _getImagePalette(FileImage(widget.image));
    _setEditingAreaSize();
    super.initState();
  }

  // https://www.youtube.com/watch?v=PTyvarfJiW8
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final photoAspectRatio = _aspectRatio;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: <Widget>[
          // Photo Editing area
          GestureDetector(
              onScaleStart: (details) {
                if (_activeItem == null) return;

                _initPos = details.focalPoint;
                _currentPos = _activeItem!.position;
                _currentScale = _activeItem!.scale;
                _currentRotation = _activeItem!.rotation;
              },
              onScaleUpdate: (details) {
                if (_activeItem == null) return;
                final delta = details.focalPoint - _initPos;
                final left = (delta.dx / screen.width) + _currentPos.dx;
                final top = (delta.dy / screen.height) + _currentPos.dy;

                setState(() {
                  _activeItem!.position = Offset(left, top);
                  _activeItem!.rotation = details.rotation + _currentRotation;
                  _activeItem!.scale = details.scale * _currentScale;
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
                    width: screen.width,
                    height: _editingAreaSize?.height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: RepaintBoundary(
                          key: _globalKey,
                          child: Stack(
                              clipBehavior: Clip.antiAlias,
                              children: <Widget>[
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
                                    child: Image.file(widget.image)),
                                ...mockData.map(_buildItemWidget).toList(),
                              ])),
                    )),
              )),
          _getTopMenu(),
        ]));
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
                        _circularButton(() {}, const Color(0x64000000),
                            const Text("T", style: TextStyle(fontSize: 28))),
                        _circularButton(() {}, const Color(0x64000000),
                            const Icon(Icons.sticky_note_2_outlined, size: 32)),
                        // Share
                        _circularButton(() {
                          // TODO: Share the edited photo, not the photo file
                          Share.shareXFiles([XFile(widget.image.path)]);
                        }, const Color(0x64000000),
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

  Widget _buildItemWidget(OverlaidWidget e) {
    final screen = MediaQuery.of(context).size;

    Widget widget;
    switch (e.type) {
      case ItemType.Text:
        widget = Text(
          e.value,
          style: TextStyle(color: Colors.white),
        );
    }

    return Positioned(
      top: e.position.dy * screen.height,
      left: e.position.dx * screen.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(
          angle: e.rotation,
          child: Listener(
            onPointerDown: (details) {
              if (_inAction) return;
              _inAction = true;
              _activeItem = e;
              _initPos = details.position;
              _currentPos = e.position;
              _currentScale = e.scale;
              _currentRotation = e.rotation;
            },
            onPointerUp: (details) {
              _inAction = false;
            },
            child: widget,
          ),
        ),
      ),
    );
  }
}

enum ItemType { Text }

class OverlaidWidget {
  Offset position = Offset(0.1, 0.1);
  double scale = 1.0;
  double rotation = 0.0;
  late ItemType type;
  late dynamic value;
}

final mockData = [
  OverlaidWidget()
    ..type = ItemType.Text
    ..value = "AQI 185"
    ..position = Offset(0.1, 0.2),
  OverlaidWidget()
    ..type = ItemType.Text
    ..value = "ลมไม่แรง 1.0 กม./ชม."
    ..position = Offset(0.1, 0.3),
  OverlaidWidget()
    ..type = ItemType.Text
    ..value = "5 จุดความร้อนใกล้ฉัน"
    ..position = Offset(0.1, 0.4)
];
