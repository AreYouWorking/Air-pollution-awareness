import 'dart:io';

import 'package:app/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/style.dart' as style;
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
          memoryWidget = AlbumPage(key: Key('$photo.count'), album: photo);
        }
      });
    }
    setState(() {});
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      // Request storage and photo permissions on iOS
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.photos,
      ].request();

      return statuses.entries.every((status) => status.value.isGranted);
    } else if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfo.androidInfo;

      final PermissionStatus status;
      if (info.version.sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      return status.isGranted;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 25, top: 20, right: 25, bottom: 20),
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
                ).then((_) {
                  if (mounted) initAsync();
                });
              },
              child: Container(
                width: double.infinity,
                height: 175,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: style.greyUI),
                child: const Icon(
                  Icons.camera_alt,
                  size: 50,
                ),
              )),
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              '- Memory -',
              textScaleFactor: 1.3,
            ),
          ),
          memoryWidget
        ],
      )),
    );
  }
}
