import 'package:Music/helpers/generateSubtitle.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Music/bloc/notification_bloc.dart';
import 'package:Music/helpers/db.dart';
import 'package:Music/models/models.dart';
import 'package:Music/routes/widgets/CoverImage.dart';
import 'package:Music/constants.dart';

class Albums extends StatefulWidget {
  @override
  _AlbumsState createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  List<Album> _albums = [];

  @override
  void initState() {
    super.initState();
    getAlbums();
  }

  getAlbums() async {
    var db = await getDB();

    var albums = Album.fromMapArray(
      await db.query(Tables.Albums, orderBy: "LOWER(name), name"),
    );

    if (!mounted) return;

    setState(() {
      _albums = albums;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return BlocListener<NotificationBloc, NotificationState>(
      listener: (_, state) {
        if (state is DownloadedNotification) {
          getAlbums();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: width10 / 4 * 2, top: 30, bottom: 7),
            child: Text("Albums", style: Theme.of(context).textTheme.headline3),
          ),
          Expanded(
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(0.3 * width10),
              itemCount: _albums.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (4.1 * width10) / (4.1 * width10 + 3 * rem),
              ),
              itemBuilder: (ctx, index) {
                var album = _albums[index];

                return CoverImage(
                  image: album.imagePath,
                  title: album.name,
                  subtitle:
                      generateSubtitle(type: "Album", numSongs: album.numSongs),
                  isBig: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
