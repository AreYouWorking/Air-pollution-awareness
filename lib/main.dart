import 'dart:async';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: const MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => MainScreen_();
}

class MainScreen_ extends State<MainScreen> {
  final ImagePicker _picker = ImagePicker();
  File? imageFile;
  dynamic _pickImageError;

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }

    if (imageFile != null) {
      final data = await readExifFromBytes(imageFile!.readAsBytesSync());
      if (data.isEmpty) {
        print("No EXIF information found");
        return;
      }
      // GPS value should be in this.
      for (final entry in data.entries) {
        print("${entry.key}: ${entry.value}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('AIR POLLUTION SMTH'),
        ),
        body: imageFile != null ? Image.file(imageFile!) : Container(),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  onPressed: () {
                    _onImageButtonPressed(ImageSource.gallery);
                  },
                  child: const Icon(Icons.photo_library)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  onPressed: () {
                    _onImageButtonPressed(ImageSource.camera);
                  },
                  child: const Icon(Icons.camera_alt)),
            )
          ],
        ));
  }
}
