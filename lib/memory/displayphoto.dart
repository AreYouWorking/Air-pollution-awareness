import 'package:flutter/material.dart';

import 'package:photo_gallery/photo_gallery.dart';

class AlbumPage extends StatefulWidget {
  final Album album;

  AlbumPage({super.key, required this.album});

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

// TODO core
class AlbumPageState extends State<AlbumPage> {
  List<Medium>? _media;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage? mediaPage = await widget.album.listMedia();
    setState(() {
      _media = mediaPage.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              children: <Widget>[
                ...?_media?.map(
                  (medium) => GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ViewerPage(medium))),
                    child: Container(
                      color: Colors.grey[300],
                      child: Image(
                        fit: BoxFit.cover,
                        // placeholder: MemoryImage(kTransparentImage),
                        image: ThumbnailProvider(
                          mediumId: medium.id,
                          mediumType: medium.mediumType,
                          highQuality: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }
}

class ViewerPage extends StatelessWidget {
  final Medium medium;

  const ViewerPage(this.medium, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? date = medium.creationDate ?? medium.modifiedDate;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: date != null ? Text(date.toLocal().toString()) : null,
        ),
        body: Container(
          alignment: Alignment.center,
          child: medium.mediumType == MediumType.image
              ? Image(
                  fit: BoxFit.cover,
                  image: PhotoProvider(mediumId: medium.id),
                )
              : null,
        ),
      ),
    );
  }
}
