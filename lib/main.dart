import 'dart:async';

import 'package:app/forecast/forecast.dart';
import 'package:app/forecast/forecast_data.dart';
import 'package:app/memory/memory.dart';
import 'package:app/utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

import '/location/selectlocation.dart';
import 'location/userposition.dart';
import 'package:app/style.dart' as style;

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Fetching available cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(MaterialApp(
        theme: ThemeData.dark(),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      )));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  late Timer _everyHour;
  ForecastData _forecastData = ForecastData();
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _forecastUpdate() async {
    var newForecastData =
        await ForecastData.init(Userposition.latitude, Userposition.longitude);
    setState(() {
      _forecastData = newForecastData;
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

      _forecastUpdate();
      _everyHour = Timer.periodic(const Duration(hours: 1), (Timer t) {
        _forecastUpdate();
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
      resizeToAvoidBottomInset: false,
      // (size themselves to avoid the onscreen keyboard)
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
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
                        _forecastUpdate();
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.near_me_outlined),
                        Flexible(
                            child: Text(
                          Userposition.display_place,
                          textScaleFactor: 0.7,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ))
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Memory(),
          Forecast(onRefresh: () async {}, data: _forecastData)
        ],
      ),
      bottomNavigationBar: Container(
        color: style.greyUI,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                label: 'Camera',
                backgroundColor: style.greyUI),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_drama),
                label: 'Forecast',
                backgroundColor: style.greyUI)
          ],
          selectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
