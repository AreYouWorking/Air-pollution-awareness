import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> _savePicture() async {
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final directory = (await getApplicationDocumentsDirectory()).path;
    print(directory); // directory = /data/user/0/com.example.app/app_flutter
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    File imgFile = File('$directory/${timestamp()}.png');
    imgFile.writeAsBytes(pngBytes!);
  }

  // https://www.youtube.com/watch?v=PTyvarfJiW8
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Editing Photo'),
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
                  Container(color: Colors.black26),
                  Image.file(widget.image),
                  ...mockData.map(_buildItemWidget).toList(),

                  // Image.file(widget.image),
                ]))),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              onPressed: _savePicture,
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
    ..value = "Hello World",
  OverlaidWidget()
    ..type = ItemType.Text
    ..value = "bla bla",
];
