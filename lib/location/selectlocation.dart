import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:app/aqicn/geofeed.dart' as aqicn;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import 'userposition.dart';

const greyUI = Color.fromRGBO(28, 28, 30, 1);

class Suggestlocation {
  final String name;
  final String? city;
  final double lat;
  final double lon;
  final double distance;

  const Suggestlocation({
    required this.name,
    required this.city,
    required this.lat,
    required this.lon,
    required this.distance,
  });

  factory Suggestlocation.fromJson(Map<String, dynamic> json) {
    return Suggestlocation(
      name: json['name'] as String,
      city: json['city'] == null ? "T" : json['city'] as String,
      lat: json['lat'] as double,
      lon: json['lon'] as double,
      distance: json['distance'] as double,
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
  const Selectlocation({super.key});

  @override
  State<Selectlocation> createState() => _SelectlocationState();
}

class _SelectlocationState extends State<Selectlocation> {
  final textController = TextEditingController();
  List<Suggestlocation>? Suggestdata;
  Widget suggestLocWidget = SizedBox.shrink();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  Future<List<Suggestlocation>> fetchSuggestlocation(
      String text, String token) async {
    text = await searchfilter(text);

    // https://api.locationiq.com/v1/autocomplete?key=YOUR_ACCESS_TOKEN&q=Empire
    const base = "https://api.geoapify.com/v1/geocode/autocomplete?";
    String filter = "filter=countrycode:th";
    String bias =
        "bias=proximity:${Userposition.proximity_longitude},${Userposition.proximity_latitude}|countrycode:th";
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
        ),
        body: Column(children: [
          Row(
            //TODO style imporve
            children: [
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Search place',
                      ),
                    ),
                  )),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'find place',
                onPressed: () async {
                  print(textController.text);
                  Suggestdata = await searchLocation(textController.text);

                  setState(() {
                    suggestLocWidget = displayLocationList(Suggestdata);
                  });
                  print("Suggestdata");
                  print(Suggestdata?.elementAt(0).name);
                },
              ),
            ],
          ),
          suggestLocWidget
        ]));
  }

  Widget displayLocationList(List<Suggestlocation>? suggestData) {
    if (Suggestdata == null) {
      return const SizedBox.shrink();
    } else {
      return Column(
          children: suggestData!.map((e) => locationText(e)).toList());
    }
  }

  InkWell locationText(Suggestlocation data) {
    String dis = "${(data.distance / 1000.0).toStringAsFixed(2)} Km";

    return InkWell(
      onTap: () {
        Navigator.pop(context, data);
      },
      child: Container(
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          height: 50,
          width: double.infinity,
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 16, 16),
            child: Text("${data.name}${data.city!} : $dis"),
          )),
    );
  }
}
