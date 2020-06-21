import 'dart:io';

import 'package:Music/constants.dart';
import 'package:Music/helpers/db.dart';
import 'package:Music/helpers/generateSubtitle.dart';
import 'package:Music/routes/widgets/SongView.dart';
import "package:flutter/material.dart";

import 'package:Music/models/models.dart';
import 'package:Music/routes/widgets/Mozaic.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;

  const ArtistPage(this.artist, {Key key}) : super(key: key);

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
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
      where: "artist LIKE ?",
      whereArgs: [widget.artist.name],
      orderBy: "LOWER(title), title",
    ));

    if (!mounted) return;

    setState(() {
      _songs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    var mozaic = widget.artist.images.length == 4;

    var screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          Stack(
            overflow: Overflow.visible,
            children: [
              Hero(
                tag: widget.artist.name,
                child: mozaic
                    ? Mozaic(widget.artist.images, screenWidth)
                    : Image.file(
                        File(widget.artist.images[0]),
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
                          widget.artist.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Text(
                        generateSubtitle(
                          type: "Artist",
                          numSongs: widget.artist.numSongs,
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
