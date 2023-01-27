import 'package:app/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:app/EditPhoto/PhotoEditor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Camera({Key? key, required this.cameras}) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;

  Future<void> _onImageTaken() async {
    try {
      final image = await controller.takePicture();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PhotoEditor(image: File(image.path))),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onImageLibPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhotoEditor(image: File(pickedFile.path))),
        );
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }

    // if (imageFile != null) {
    //   final data = await readExifFromBytes(imageFile!.readAsBytesSync());
    //   if (data.isEmpty) {
    //     print("No EXIF information found");
    //     return;
    //   }
    //   // GPS value should be in this.
    //   for (final entry in data.entries) {
    //     print("${entry.key}: ${entry.value}");
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();

    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
        body: Container(
          color: Colors.black,
          height: double.infinity,
          width: double.infinity,
          child: CameraPreview(controller),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _onImageLibPressed(ImageSource.gallery);
                  },
                  child: const Icon(Icons.photo_library)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _onImageTaken();
                  },
                  child: const Icon(Icons.camera_alt)),
            ),
          ],
        ));
  }
}
