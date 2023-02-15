import 'dart:io';

import 'package:app/Camera.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/memory/displayphoto.dart';

class Memory extends StatefulWidget {
  const Memory({super.key});

  @override
  State<Memory> createState() => _MemoryState();
}

class _MemoryState extends State<Memory> {
  Widget memoryWidget = const SizedBox.shrink();

  List<Album>? _albums;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      setState(() {
        print("Album setState");
        _albums = albums;
        Album photo =
            _albums!.firstWhere((element) => element.name == "AirWareness");
        if (photo.count > 0) {
          memoryWidget = AlbumPage(photo);
        }
      });
    }
    setState(() {});
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Center(
          child: Column(
        children: [
          InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Camera()),
                );
              },
              child: Container(
                width: 330,
                height: 175,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), color: greyUI),
                child: const Icon(
                  Icons.camera_alt,
                  size: 50,
                ),
              )),
//           GestureDetector(
//               onTap: () async {
//                 setState(() {
//                   print("test");
//                   print("object");
//                   initAsync();
//                   print(_albums?.elementAt(0));
//                   test();
//                 });
//               },
//               child: Column(children: const [
//                 Text(
//                   "test",
//                   textScaleFactor: 0.7,
//                 ),
//               ])
//TODO style imporve
          memoryWidget
        ],
      )),
    );
  }
}
