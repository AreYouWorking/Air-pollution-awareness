import 'dart:async';

import 'package:app/forecast.dart';
import 'package:app/memory.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

const greyUI = Color.fromRGBO(28, 28, 30, 1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: const MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
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

  int _selectedIndex = 1;

  static const List<Widget> _widgetOptions = <Widget>[
    Memory(),
    Forecast(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        color: greyUI,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt), label: 'camera', backgroundColor: greyUI),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_drama), label: 'forecast', backgroundColor: greyUI)
          ],
          selectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Container gpsButton() {
    return Container(
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
    );
  }

}
