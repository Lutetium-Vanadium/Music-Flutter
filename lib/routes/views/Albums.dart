import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:focused_menu/modals.dart";

import "package:Music/bloc/queue_bloc.dart";
import 'package:Music/bloc/data_bloc.dart';
import "package:Music/helpers/generateSubtitle.dart";
import "package:Music/helpers/db.dart";
import "package:Music/models/models.dart";
import "package:Music/constants.dart";
import "package:Music/routes/widgets/CoverImage.dart";

class Albums extends StatefulWidget {
  @override
  _AlbumsState createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  List<AlbumData> _albums = [];
  List<CustomAlbumData> _customAlbums = [];
  int _numLiked;

  @override
  void initState() {
    super.initState();
    getAlbums();
  }

  getAlbums() async {
    var db = await getDB();

    var albums = AlbumData.fromMapArray(
      await db.query(Tables.Albums, orderBy: "LOWER(name), name"),
    );

    var customAlbums = CustomAlbumData.fromMapArray(
      await db.query(Tables.CustomAlbums, orderBy: "LOWER(name), name"),
    );

    int numLiked = (await db.rawQuery(
        "SELECT COUNT(*) AS cnt FROM ${Tables.Songs} WHERE liked;"))[0]["cnt"];

    if (!mounted) return;

    setState(() {
      _albums = albums;
      _customAlbums = customAlbums;
      _numLiked = numLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return MultiBlocListener(
      listeners: [
        BlocListener<DataBloc, DataState>(
          listener: (_, state) {
            print(state);
            if (state is UpdateData) {
              getAlbums();
            }
          },
        ),
        BlocListener<QueueBloc, QueueState>(
          listener: (_, state) {
            if (state.updateData) {
              getAlbums();
            }
          },
        ),
      ],
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.only(left: width10 / 4 * 2, top: 30, bottom: 7),
              child: Text("Custom Albums",
                  style: Theme.of(context).textTheme.headline3),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(0.3 * width10),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (4.1 * width10) / (4.1 * width10 + 3 * rem),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, _index) {
                  var index = _index - 1;

                  if (_index == 0) {
                    return CoverImage(
                      image: "liked.png",
                      isAssetImage: true,
                      title: "Liked",
                      subtitle:
                          generateSubtitle(type: "Album", numSongs: _numLiked),
                      isBig: true,
                      tag: "liked-songs",
                      onClick: () {
                        Navigator.of(context).pushNamed("/liked");
                      },
                      focusedMenuItems: [
                        FocusedMenuItem(
                          onPressed: () async {
                            var db = await getDB();
                            var songs = SongData.fromMapArray(await db.query(
                              Tables.Songs,
                              where: "liked",
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
                  }
                  if (index == _customAlbums.length) {
                    return Container(
                      margin: EdgeInsets.all(width10 * 0.3),
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed("/select-songs"),
                        child: Container(
                          width: 4.1 * width10,
                          height: 4.1 * width10,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add, size: 50),
                        ),
                      ),
                    );
                  }

                  var album = _customAlbums[index];

                  return CoverImage(
                    image: "music_symbol.png",
                    isAssetImage: true,
                    title: album.name,
                    subtitle: generateSubtitle(
                        type: "Album", numSongs: album.songs.length),
                    isBig: true,
                    tag: album.id,
                    onClick: () {
                      Navigator.of(context)
                          .pushNamed("/album", arguments: album);
                    },
                    focusedMenuItems: [
                      FocusedMenuItem(
                        onPressed: () async {
                          var db = await getDB();
                          String songNames =
                              CustomAlbumData.toMap(album)["songs"];
                          var songs = SongData.fromMapArray(await db.rawQuery(
                            "SELECT * from ${Tables.Songs} WHERE title IN ($songNames) ORDER BY LOWER(title), title;",
                          ));
                          BlocProvider.of<QueueBloc>(context)
                              .add(EnqueueSongs(songs: songs));
                        },
                        title: Text("Play"),
                        trailingIcon: Icon(Icons.playlist_play),
                        backgroundColor: Colors.transparent,
                      ),
                      FocusedMenuItem(
                        onPressed: () async {
                          BlocProvider.of<DataBloc>(context)
                              .add(DeleteCustomAlbum(album.id));
                        },
                        title:
                            Text("Delete", style: TextStyle(color: Colors.red)),
                        trailingIcon: Icon(Icons.delete, color: Colors.red),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  );
                },
                childCount: _customAlbums.length + 2,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.only(left: width10 / 4 * 2, top: 30, bottom: 7),
              child:
                  Text("Albums", style: Theme.of(context).textTheme.headline3),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(0.3 * width10),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (4.1 * width10) / (4.1 * width10 + 3 * rem),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var album = _albums[index];

                  return CoverImage(
                    image: album.imagePath,
                    title: album.name,
                    subtitle: generateSubtitle(
                        type: "Album", numSongs: album.numSongs),
                    isBig: true,
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
                childCount: _albums.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
