import 'dart:io';
import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';

import 'package:Music/constants.dart';
import 'package:Music/routes/models/CoverImage.dart';
import "package:Music/helpers/db.dart";
import "package:Music/dataClasses.dart";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Song> _topSongs = [];
  List<Album> _topAlbums = [];

  @override
  void initState() {
    super.initState();

    getTop();
  }

  Future<void> getTop() async {
    var db = await getDB();

    // SECTION dev helpers

    // Clear Database Contents
    // db.delete(Tables.Albums);
    // db.delete(Tables.Songs);
    // db.delete(Tables.CustomAlbums);

    // Delete Songs
    // File("${(await getApplicationDocumentsDirectory()).path}/songs")
    //     .delete(recursive: true);

    // Delete album covers
    // File("${(await getApplicationDocumentsDirectory()).path}/album_images")
    //     .delete(recursive: true);

    // List all files ignoring flutter stuff
    // var dirs =
    //     (await getApplicationDocumentsDirectory()).listSync(recursive: true);
    // var base = "/data/user/0/com.example.Music/app_flutter";
    // var toSee = [RegExp("$base/songs/*"), RegExp("$base/album_images/*")];
    // dirs.retainWhere((element) =>
    //     toSee[0].hasMatch(element.path) || toSee[1].hasMatch(element.path));
    // print("[\n\t${dirs.join(",\n\t")}\n]");

    // !SECTION

    var topSongs = Song.fromMapArray(
      await db.query(Tables.Songs, orderBy: "numListens DESC", limit: 5),
    );
    var topAlbums = Album.fromMapArray(
      await db.query(Tables.Albums, orderBy: "numSongs DESC", limit: 5),
    );

    if (!mounted) return;

    setState(() {
      _topSongs = topSongs;
      _topAlbums = topAlbums;
    });
    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(left: width10 / 4 * 2, top: 30, bottom: 7),
              child: Text("Top Albums",
                  style: Theme.of(context).textTheme.headline3),
            ),
            Container(
              height: 4.3 * width10 + 3 * rem,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: width10 / 4),
                scrollDirection: Axis.horizontal,
                itemCount: _topAlbums.length,
                itemBuilder: (ctx, index) {
                  var album = _topAlbums[index];
                  return CoverImage(
                    image: album.imagePath,
                    title: album.name,
                    subtitle: "Album · ${album.artist}",
                  );
                },
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: width10 / 4 * 2, bottom: 7),
              child: Text("Top Songs",
                  style: Theme.of(context).textTheme.headline3),
            ),
            Container(
              height: 4.3 * width10 + 3 * rem,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: width10 / 4),
                scrollDirection: Axis.horizontal,
                itemCount: _topSongs.length,
                itemBuilder: (ctx, index) {
                  var song = _topSongs[index];
                  return CoverImage(
                    image: song.thumbnail,
                    title: song.title,
                    subtitle: "Song · ${song.artist}",
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
