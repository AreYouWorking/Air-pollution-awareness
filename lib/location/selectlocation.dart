import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';
import 'userposition.dart';

const greyUI = Color.fromRGBO(28, 28, 30, 1);

class Suggestlocation {
  final String? name;
  final String? city;
  final double lat;
  final double lon;
  final double? distance;

  const Suggestlocation({
    required this.name,
    required this.city,
    required this.lat,
    required this.lon,
    required this.distance,
  });

  factory Suggestlocation.fromJson(Map<String, dynamic> json) {
    return Suggestlocation(
      // Try 'name', if null try 'formatted', if null try 'address_line1', etc.
      name: json['name'] as String? ?? 
            json['formatted'] as String? ?? 
            json['address_line1'] as String? ?? 
            json['state'] as String?,
            
      // Try 'city', if null try 'state', if null try 'county'
      city: json['city'] as String? ?? 
            json['state'] as String? ?? 
            json['county'] as String?,

      // Use 'num' to safely handle both int and double values from JSON
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      
      // Handle potential null distance
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}

// A function that converts a response body into a List<Suggestlocation>.
List<Suggestlocation> parseJson(String responseBody) {
  final parsed =
      jsonDecode(responseBody)["results"].cast<Map<String, dynamic>>();

  return parsed
      .map<Suggestlocation>((json) => Suggestlocation.fromJson(json))
      .toList();
}

class Selectlocation extends StatefulWidget {
  const Selectlocation({super.key, required this.predefinedLocation});

  final List<Suggestlocation> predefinedLocation;

  @override
  State<Selectlocation> createState() => _SelectlocationState();
}

class _SelectlocationState extends State<Selectlocation> {
  final textController = TextEditingController();
  List<Suggestlocation>? suggestData;
  Widget suggestLocWidget = const SizedBox.shrink();
  Widget userGPSLocWidget = const SizedBox.shrink();
  Widget predefinedLocWidget = const SizedBox.shrink();

  Timer? _debounce;
  static const int searchDelayInMs = 300;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    _refreshUserLocWidget();
    setState(() {
      predefinedLocWidget = displayLocationList(widget.predefinedLocation);
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onPressedRefreshUserLoc() async {
    setState(() {
      _isFetchingLocation = true;
    });
    textController.clear();
    await fetchAndSetUserLocation();
    print(UserPosition.displayPlaceGPS);
    _refreshUserLocWidget();
    setState(() {
      _isFetchingLocation = false;
    });
  }

  void _refreshUserLocWidget() {
    if (UserPosition.latitudeGPS == '' || UserPosition.longitudeGPS == '') {
      return;
    }

    setState(() {
      userGPSLocWidget = locationText(Suggestlocation(
          name: UserPosition.displayPlaceGPS,
          city: null,
          lat: double.parse(UserPosition.latitudeGPS),
          lon: double.parse(UserPosition.longitudeGPS),
          distance: null));
    });
  }

  Future<List<Suggestlocation>> fetchSuggestlocation(
      String text, String token) async {
    text = await searchfilter(text);

    // https://api.locationiq.com/v1/autocomplete?key=YOUR_ACCESS_TOKEN&q=Empire
    const base = "https://api.geoapify.com/v1/geocode/autocomplete?";
    String filter = "filter=countrycode:th";
    String bias =
        "bias=proximity:${UserPosition.proximityLongitude},${UserPosition.proximityLatitude}|countrycode:th";
    String format = "format=json";
    String params = "text=$text&$filter&$bias&$format&apiKey=$token";
    print(base + params);
    final response = await http.get(Uri.parse(base + params));
    print(jsonDecode(response.body)["results"]);
    if (response.statusCode == 200) {
      return compute(parseJson, response.body);
    } else {
      throw Exception("Failed to load location.");
    }
  }

  Future<String> searchfilter(String text) async {
    String resp = text;
    switch (text) {
      case "สุเทพ":
        return "Doi Suthep";
      case "มช":
        return "Chiang Mai University";
    }
    return resp;
  }

  Future<List<Suggestlocation>> searchLocation(String text) async {
    var token = dotenv.env["GEOAPI_KEY"];
    if (token == null) {
      throw Exception("Please set GEOAPI_KEY in .env file");
    }
    List<Suggestlocation> resp = await fetchSuggestlocation(text, token);
    print(resp);

    return resp;
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('เลือกตำแหน่งที่อยู่'),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 20, 8),
              child: InkWell(
                  onTap: _isFetchingLocation ? null : _onPressedRefreshUserLoc,
                  child: _isFetchingLocation
                      ? Transform.scale(
                          scale: 0.6,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 5,
                          ))
                      : const Icon(Icons.refresh, size: 32)),
            )
          ],
        ),
        body: Column(children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onChanged: _onSearchChanged,
                  controller: textController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    hintText: 'Search for location',
                  ),
                  style: const TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
          Expanded(
              child: Listener(
            onPointerUp: (_) {
              hideKeyboard();
            },
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (textController.text.trim().length > 1)
                  const SizedBox.shrink()
                else ...[userGPSLocWidget, predefinedLocWidget],
                suggestLocWidget
              ],
            ),
          ))
        ]));
  }

  _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: searchDelayInMs), () async {
      print('searchLocation text: $text');
      if (text.trim().length > 1) {
        setState(() {
          _isFetchingLocation = true;
        });
        suggestData = await searchLocation(textController.text);
        setState(() {
          suggestLocWidget = displayLocationList(suggestData);
          _isFetchingLocation = false;
        });
      } else {
        setState(() {
          suggestLocWidget = Container();
          _isFetchingLocation = false;
        });
      }
    });
  }

  void hideKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }

  Widget displayLocationList(List<Suggestlocation>? data) {
    if (data == null) {
      return const SizedBox.shrink();
    } else {
      return Column(children: data.map((e) => locationText(e)).toList());
    }
  }

  InkWell locationText(Suggestlocation data) {
    String? label =
        data.city != null ? "${data.name} (${data.city})" : data.name;

    return InkWell(
      onTap: () {
        Navigator.pop(context, data);
      },
      child: Container(
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          width: double.infinity,
          color: Colors.black,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  data.distance != null
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 6, 6, 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Distance: ${(data.distance! / 1000.0).toStringAsFixed(2)} Km",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white70),
                              )),
                        )
                      : const SizedBox.shrink()
                ],
              ))),
    );
  }
}
