import 'dart:async';
import 'dart:convert';

import 'package:app/forecast.dart';
import 'package:app/memory.dart';
import 'package:app/openmetro/airquality.dart';
import 'package:app/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  late String lat = "";
  late String long = "";

  int _selectedIndex = 1;
  static const _widgetOptions = <Widget>[
    Memory(),
    Forecast(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _initData() async {
    try {
      Position v = await getCurrentLocation();
      setState(() {
        lat = "${v.latitude}";
        long = "${v.longitude}";
      });
    } catch (_) {
      // TODO: do something if can't fetch gps location
    }
  }

  @override
  void initState() {
    super.initState();
    _initData().whenComplete(() => null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true, // (size themselves to avoid the onscreen keyboard)
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AirWareness',
              textScaleFactor: 1.2,
            ),
            Text(
              "$lat, $long",
              textScaleFactor: 0.7,
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        color: greyUI,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'camera',
                backgroundColor: greyUI),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_drama),
                label: 'forecast',
                backgroundColor: greyUI)
          ],
          selectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
