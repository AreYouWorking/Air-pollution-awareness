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
const greyUI = Color.fromRGBO(28, 28, 30, 1);

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'AirWareness',
              textScaleFactor: 1.2,
            ),
            Text(
              'Suthep ChiangMai',
              textScaleFactor: 0.7,
            )
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 40, top: 20),
        child: Column(
          children: <Widget>[
            todayWidget(),
            dailyWidget(),
            hourlyWidget(),
          ],
        ),
      ),
      floatingActionButton: Container(
        color: greyUI,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  backgroundColor: greyUI,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                  backgroundColor: greyUI,
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
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Column hourlyWidget() {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hourly',
                textScaleFactor: 1.3,
              ),
              Container(
                decoration: BoxDecoration(
                    color: greyUI, borderRadius: BorderRadius.circular(15.0)),
                height: 200,
                width: 320,
              )
            ],
          );
  }

  Container dailyWidget() {
    return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily',
                  textScaleFactor: 1.3,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: greyUI, borderRadius: BorderRadius.circular(15.0)),
                  height: 175,
                  width: 320,
                )
              ],
            ),
          );
  }

  Container todayWidget() {
    return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today',
                  textScaleFactor: 1.3,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 77, 0, 1),
                      borderRadius: BorderRadius.circular(15.0)),
                  height: 200,
                  width: 320,
                )
              ],
            ),
          );
  }
}
