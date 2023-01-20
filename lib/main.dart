import 'dart:async';
import 'dart:io';

import 'package:app/EditPhoto/PhotoEditor.dart';
import 'package:app/Camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

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
  // File? imageFile;
  dynamic _pickImageError;

  // get current location from GPS
  String locationMsg = 'Current Location of the user';
  late String lat;
  late String long;

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        // setState(() {
        //   imageFile = File(pickedFile.path);
        // });
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

  // get current location using Geolocator
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request location');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('APA Photo Sharing'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                locationMsg,
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
                    _getCurrentLocation().then((value) {
                      lat = '${value.latitude}';
                      long = '${value.longitude}';
                      setState(() {
                        locationMsg = 'Latitude: $lat, Longitude: $long';
                      });
                    });
                  },
                  child: const Icon(Icons.gps_fixed)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _onImageButtonPressed(ImageSource.gallery);
                  },
                  child: const Icon(Icons.photo_library)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Camera(cameras: _cameras)),
                    );
                  },
                  child: const Icon(Icons.camera_alt)),
            ),
          ],
        ));
  }
}
