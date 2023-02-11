import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:app/aqicn/geofeed.dart' as aqicn;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

const greyUI = Color.fromRGBO(28, 28, 30, 1);

class Suggestlocation {
  final String place_name;
  final String place_detail;

  final String lat;
  final String lon;

  const Suggestlocation({
    required this.place_name,
    required this.place_detail,
    required this.lat,
    required this.lon,
  });

  factory Suggestlocation.fromJson(Map<String, dynamic> json) {
    return Suggestlocation(
      place_name: json['display_place'] as String,
      place_detail: json['display_name'] as String,
      lat: json['lat'] as String,
      lon: json['lon'] as String,
    );
  }
}

// A function that converts a response body into a List<Suggestlocation>.
List<Suggestlocation> parseJson(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

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
    // https://api.locationiq.com/v1/autocomplete?key=YOUR_ACCESS_TOKEN&q=Empire
    const base = "https://api.locationiq.com/v1/autocomplete?";
    String params = "key=$token&countrycodes=th&q=$text";
    print(base + params);
    final response = await http.get(Uri.parse(base + params));
    if (response.statusCode == 200) {
      return compute(parseJson, response.body);
    } else {
      throw Exception("Failed to load location.");
    }
  }

  Future<List<Suggestlocation>> searchLocation(String text) async {
    var token = dotenv.env["LOCAQ_KEY"];
    if (token == null) {
      throw Exception("Please set LOCAQ_KEY in .env file");
    }
    List<Suggestlocation> resp = await fetchSuggestlocation(text, token);

    return resp;
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    return Scaffold(
        appBar: AppBar(
          title: const Text('เลือกตำแหน่งที่อยู่'),
        ),
        body: Column(children: [
          Row(
            //TODO style imporve
            children: [
              Expanded(
                  flex: 2,
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search place',
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
                  print(Suggestdata?.elementAt(0).place_name);
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
    return InkWell(
      onTap: () {
        Navigator.pop(context, data);
      },
      child: Container(
          height: 50, color: Colors.grey, child: Text(data.place_detail)),
    );
  }
}
