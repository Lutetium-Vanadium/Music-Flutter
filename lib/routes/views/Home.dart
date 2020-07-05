import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:focused_menu/modals.dart";

import "package:Music/global_providers/database.dart";
import "package:Music/bloc/data_bloc.dart";
import "package:Music/bloc/queue_bloc.dart";
import "package:Music/constants.dart";
import "package:Music/models/models.dart";
import "package:Music/helpers/displace.dart";
import "package:Music/helpers/generateSubtitle.dart";

import "../widgets/CoverImage.dart";
import "../widgets/showConfirm.dart";

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

    // var db = DatabaseProvider.getDB(context);
    // // Print Database Contents
    // print("===== Songs =====");
    // (await db.getSongs()).forEach(print);
    // print("===== Albums ====");
    // (await db.getAlbums()).forEach(print);
    // print("== CustomAlbums =");
    // (await db.getCustomAlbums()).forEach(print);
    // print("==================");
    // // Clear Database Contents
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
    var db = DatabaseProvider.getDB(context);
    var topData = await db.getTopData();

    if (!mounted) return;

    setState(() {
      _topSongs = topData.first;
      _topAlbums = topData.second;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return MultiBlocListener(
      listeners: [
        BlocListener<DataBloc, DataState>(
          listener: (_, state) {
            if (state is UpdateData) {
              getTop();
            }
          },
        ),
        BlocListener<QueueBloc, QueueState>(
          listener: (context, state) {
            if (state.updateData) {
              getTop();
            }
          },
        ),
      ],
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: width10 / 2, top: 30, bottom: 7),
                child: Text(
                  "Top Albums",
                  style: Theme.of(context).textTheme.headline3,
                ),
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
                            var songs = await DatabaseProvider.getDB(context)
                                .getSongs(
                                    where: "albumId LIKE ?",
                                    whereArgs: [album.id]);
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
                padding: EdgeInsets.only(left: width10 / 2, bottom: 7),
                child: Text(
                  "Top Songs",
                  style: Theme.of(context).textTheme.headline3,
                ),
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
                          onPressed: () => Navigator.of(context)
                              .pushNamed("/add-to-album", arguments: song),
                          title: Text("Add to Album"),
                          trailingIcon: Icon(Icons.playlist_add),
                          backgroundColor: Colors.transparent,
                        ),
                        FocusedMenuItem(
                          onPressed: () {
                            BlocProvider.of<QueueBloc>(context)
                                .add(ToggleLikedSong(song));
                          },
                          title: song.liked ? Text("Unlike") : Text("Like"),
                          trailingIcon: song.liked
                              ? Icon(Icons.favorite)
                              : Icon(Icons.favorite_border),
                          backgroundColor: Colors.transparent,
                        ),
                        FocusedMenuItem(
                          onPressed: () async {
                            if (await showConfirm(
                              context,
                              "Delete ${song.title}",
                              "Are you sure you want to delete ${song.title} by ${song.artist}?",
                            )) {
                              BlocProvider.of<DataBloc>(context)
                                  .add(DeleteSong(song));
                            }
                          },
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
