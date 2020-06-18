import 'dart:io';

import "package:flutter/material.dart";
import "package:Music/helpers/db.dart";
import "package:Music/dataClasses.dart";
import 'package:path_provider/path_provider.dart';

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

    // db.delete(Tables.Albums);
    // db.delete(Tables.Songs);
    // File("${(await getApplicationDocumentsDirectory()).path}/songs")
    //     .delete(recursive: true);
    var dirs =
        (await getApplicationDocumentsDirectory()).listSync(recursive: true);
    var base = "/data/user/0/com.example.Music/app_flutter";
    var toSee = [RegExp("$base/songs/*"), RegExp("$base/album_images/*")];
    dirs.retainWhere((element) =>
        toSee[0].hasMatch(element.path) || toSee[1].hasMatch(element.path));
    print("[\n\t${dirs.join(",\n\t")}\n]");

    var topSongs = Song.fromMapArray(
      await db.query(Tables.Songs, orderBy: "numListens DESC", limit: 5),
    );
    var topAlbums = Album.fromMapArray(
      await db.query(Tables.Albums, orderBy: "numSongs DESC", limit: 5),
    );

    if (!mounted) return;

    print(topSongs);
    print(topAlbums);

    setState(() {
      _topSongs = topSongs;
      _topAlbums = topAlbums;
    });
    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Home ${_topSongs.length} ${_topAlbums.length}",
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
