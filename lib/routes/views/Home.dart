import "dart:io";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:focused_menu/modals.dart";

import "package:Music/bloc/notification_bloc.dart";
import "package:Music/bloc/queue_bloc.dart";
import "package:Music/constants.dart";
import "package:Music/models/models.dart";
import "package:Music/helpers/displace.dart";
import "package:Music/helpers/generateSubtitle.dart";
import "package:Music/helpers/db.dart";

import "../widgets/CoverImage.dart";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<SongData> _topSongs = [];
  List<AlbumData> _topAlbums = [];

  @override
  void initState() {
    super.initState();

    getTop();
  }

  Future<void> dev() async {
    // SECTION dev helpers

    // // Clear Database Contents
    // var db = await getDB();
    // print("===== Songs =====");
    // SongData.fromMapArray(await db.query(Tables.Songs)).forEach(print);
    // print("===== Albums ====");
    // AlbumData.fromMapArray(await db.query(Tables.Albums)).forEach(print);
    // print("== CustomAlbums =");
    // CustomAlbumData.fromMapArray(await db.query(Tables.CustomAlbums)).forEach(print);
    // print("==================");
    // db.delete(Tables.Albums);
    // db.delete(Tables.Songs);
    // db.delete(Tables.CustomAlbums);
    // // Delete Songs
    // File("${(await getApplicationDocumentsDirectory()).path}/songs")
    //     .delete(recursive: true);

    // // Delete album covers
    // File("${(await getApplicationDocumentsDirectory()).path}/album_images")
    //     .delete(recursive: true);

    // // List all files ignoring flutter stuff
    // var dirs =
    //     (await getApplicationDocumentsDirectory()).listSync(recursive: true);
    // var base = "/data/user/0/com.example.Music/app_flutter";
    // var toSee = [RegExp("$base/songs/*"), RegExp("$base/album_images/*")];
    // dirs.retainWhere((element) =>
    //     toSee[0].hasMatch(element.path) || toSee[1].hasMatch(element.path));
    // print("[\n\t${dirs.join(",\n\t")}\n]");
    // !SECTION
  }

  Future<void> getTop() async {
    // await dev();
    var db = await getDB();

    var topSongs = SongData.fromMapArray(
      await db.query(Tables.Songs, orderBy: "numListens DESC", limit: 5),
    );
    var topAlbums = AlbumData.fromMapArray(
      await db.query(Tables.Albums, orderBy: "numSongs DESC", limit: 5),
    );

    if (!mounted) return;

    setState(() {
      _topSongs = topSongs;
      _topAlbums = topAlbums;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return BlocListener<NotificationBloc, NotificationState>(
      listener: (_, state) {
        if (state is DownloadedNotification) {
          getTop();
        }
      },
      child: ListView(
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
                      subtitle:
                          generateSubtitle(type: "Album", artist: album.artist),
                      tag: album.id,
                      onClick: () {
                        Navigator.of(context)
                            .pushNamed("/album", arguments: album);
                      },
                      focusedMenuItems: [
                        FocusedMenuItem(
                          onPressed: () async {
                            var db = await getDB();
                            var songs = SongData.fromMapArray(await db.query(
                              Tables.Songs,
                              where: "albumId LIKE ?",
                              whereArgs: [album.id],
                              orderBy: "LOWER(title), title",
                            ));
                            BlocProvider.of<QueueBloc>(context)
                                .add(EnqueueSongs(songs: songs));
                          },
                          title: Text("Play"),
                          trailingIcon: Icon(Icons.playlist_play),
                          backgroundColor: Colors.transparent,
                        ),
                      ],
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
                      subtitle:
                          generateSubtitle(type: "Song", artist: song.artist),
                      onClick: () {
                        BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
                          songs: displace(_topSongs, index),
                        ));
                      },
                      focusedMenuItems: [
                        FocusedMenuItem(
                          onPressed: () {
                            BlocProvider.of<QueueBloc>(context)
                                .add(EnqueueSongs(
                              songs: displace(_topSongs, index),
                            ));
                          },
                          title: Text("Play"),
                          trailingIcon: Icon(Icons.play_arrow),
                          backgroundColor: Colors.transparent,
                        ),
                        FocusedMenuItem(
                          onPressed: () {},
                          title: Text("Like"),
                          trailingIcon: Icon(Icons.favorite_border),
                          backgroundColor: Colors.transparent,
                        ),
                        FocusedMenuItem(
                          onPressed: () {},
                          title: Text("Delete",
                              style: TextStyle(color: Colors.red)),
                          trailingIcon: Icon(Icons.delete, color: Colors.red),
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
