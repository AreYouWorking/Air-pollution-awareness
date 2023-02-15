import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class PhotoEditor extends StatefulWidget {
  const PhotoEditor({super.key, required this.image});

  final File image;

  @override
  State<StatefulWidget> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  final GlobalKey _globalKey = GlobalKey();

  OverlaidWidget? _activeItem;

  late Offset _initPos;

  late Offset _currentPos;

  late double _currentScale;

  late double _currentRotation;

  late bool _inAction;

  bool _isSaving = false;

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
    await GallerySaver.saveImage(imgFile.path, albumName: 'AirWareness');
    setState(() {
      _isSaving = false;
    });
  }

  // https://www.youtube.com/watch?v=PTyvarfJiW8
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Editing Photo'),
          backgroundColor: Colors.black,
        ),
        body: GestureDetector(
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
            child: RepaintBoundary(
                key: _globalKey,
                child: Stack(children: [
                  Container(color: Colors.black),
                  Image.file(widget.image),
                  ...mockData.map(_buildItemWidget).toList(),

                  // Image.file(widget.image),
                ]))),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 20),
            child: FloatingActionButton(
              backgroundColor: const ui.Color.fromARGB(255, 255, 60, 0),
              foregroundColor: Colors.white,
              onPressed: !_isSaving ? _savePicture : null,
              child: const Icon(Icons.save),
            ),
          )
        ]));
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
