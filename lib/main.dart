import 'dart:async';

import 'package:app/aqicn/geofeed.dart' as aqicn;
import 'package:app/forecast.dart';
import 'package:app/memory.dart';
import 'package:app/openmetro/airquality.dart';
import 'package:app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import 'package:app/location/selectlocation.dart' as select;
import 'package:app/location/userposition.dart' as position;
import 'package:intl/intl.dart';

import '/location/selectlocation.dart';
import 'location/userposition.dart';

const greyUI = Color.fromRGBO(28, 28, 30, 1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: const MainScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  Airquality? data;
  aqicn.Data? aqicnData;

  int _selectedIndex = 1;
  Widget currBody = Forecast();
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        currBody = const Memory();
      } else {
        currBody = Forecast(data: data, aqicnData: aqicnData);
        setState(() {});
      }
    });
  }

  Future<void> _initData() async {
    try {
      Position v = await getCurrentLocation();
      Userposition.proximity_latitude = "${v.latitude}";
      Userposition.proximity_longitude = "${v.longitude}";
      Userposition.latitude = "${v.latitude}";
      Userposition.longitude = "${v.longitude}";

      Userposition.display_place = await getCurrentPlaceName();
      forecastupdate();
    } catch (_) {
      // TODO: do something if can't fetch gps location
    }
  }

  Future<void> forecastupdate() async {
    try {
      data = await getAirQuality5day(
          Userposition.latitude, Userposition.longitude);
      aqicnData =
          await aqicn.getData(Userposition.latitude, Userposition.longitude);
      currBody = Forecast(data: data, aqicnData: aqicnData);
      setState(() {});
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
      resizeToAvoidBottomInset:
          false, // (size themselves to avoid the onscreen keyboard)
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

            //make it clikable to set location
            GestureDetector(
                onTap: () async {
                  final chosenLocation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Selectlocation(),
                      ));
                  print(chosenLocation);
                  setState(() {
                    print("data");
                    Userposition.display_place = chosenLocation.name;
                    Userposition.latitude = chosenLocation.lat.toString();
                    Userposition.longitude = chosenLocation.lon.toString();
                    print(Userposition.display_place);
                    forecastupdate();
                  });
                },
                child: Column(children: [
                  Text(
                    Userposition.display_place,
                    textScaleFactor: 0.7,
                  ),
                  Text(
                    "${Userposition.latitude.isNotEmpty ? Userposition.latitude.substring(0, 7) : Userposition.latitude}, ${Userposition.longitude.isNotEmpty ? Userposition.longitude.substring(0, 7) : Userposition.longitude}",
                    textScaleFactor: 0.7,
                  )
                ])),
          ],
        ),
      ),
      body: currBody,
      bottomNavigationBar: Container(
        color: greyUI,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                label: 'Camera',
                backgroundColor: greyUI),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_drama),
                label: 'Forecast',
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
