import 'dart:io';
import 'dart:ui';
import "package:flutter/material.dart";

import 'package:Music/constants.dart';
import 'package:Music/models/models.dart';
import 'package:Music/helpers/db.dart';
import 'package:Music/helpers/generateSubtitle.dart';
import 'package:Music/routes/widgets/SongView.dart';

class AlbumPage extends StatefulWidget {
  final Album album;

  const AlbumPage(this.album, {Key key}) : super(key: key);

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<Song> _songs = [];

  @override
  void initState() {
    super.initState();
    getSongs();
  }

  Future<void> getSongs() async {
    var db = await getDB();

    var songs = Song.fromMapArray(await db.query(
      Tables.Songs,
      where: "albumId LIKE ?",
      whereArgs: [widget.album.id],
      orderBy: "LOWER(title), title",
    ));

    if (!mounted) return;

    setState(() {
      _songs = List.generate(10, (index) => songs[0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          Stack(
            overflow: Overflow.visible,
            children: [
              Hero(
                tag: widget.album.id,
                child: Image.file(
                  File(widget.album.imagePath),
                  width: screenWidth,
                  height: screenWidth,
                ),
              ),
              Container(
                width: screenWidth,
                height: screenWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).backgroundColor.withOpacity(0.2),
                      Theme.of(context).backgroundColor.withOpacity(0.2),
                      Theme.of(context).backgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: Navigator.of(context).pop,
                ),
              ),
              SizedBox(
                height: screenWidth,
                width: screenWidth,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: screenWidth / 4,
                      ),
                      Container(
                        constraints:
                            BoxConstraints(maxWidth: 0.8 * screenWidth),
                        child: Text(
                          widget.album.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Text(
                        generateSubtitle(
                          type: "Album",
                          artist: widget.album.artist,
                        ),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: ButtonBar(
                  buttonHeight: 2.5 * rem,
                  buttonMinWidth: 0.25 * screenWidth,
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      color: Theme.of(context).buttonColor,
                      onPressed: () {},
                      child: Text("Play All"),
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      color: Theme.of(context).buttonColor,
                      onPressed: () {},
                      child: Text("Play Random"),
                    ),
                  ],
                ),
                bottom: -2 * rem,
                left: 0.2 * screenWidth,
                width: 0.6 * screenWidth,
              ),
            ],
          ),
          SizedBox(height: 30),
          Expanded(
            child: SongView(
              songs: _songs,
              isLocal: true,
              onClick: (song, i) {
                print(song);
              },
            ),
          ),
        ],
      ),
    );
  }
}
