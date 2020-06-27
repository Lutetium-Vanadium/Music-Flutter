import "dart:io";
import "package:flutter/material.dart";

import "package:Music/models/models.dart";
import "package:Music/helpers/db.dart";
import "package:Music/helpers/generateSubtitle.dart";
import "package:Music/routes/widgets/SongPage.dart";

import "./widgets/Mozaic.dart";

class ArtistPage extends StatefulWidget {
  final ArtistData artist;

  const ArtistPage(this.artist, {Key key}) : super(key: key);

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage>
    with SingleTickerProviderStateMixin {
  List<SongData> _songs = [];
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    beginAnimation();
    getSongs();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> beginAnimation() async {
    await Future.delayed(const Duration(milliseconds: 450));
    await _controller.forward();
  }

  Future<void> getSongs() async {
    var db = await getDB();

    var songs = SongData.fromMapArray(await db.query(
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
    var screenWidth = MediaQuery.of(context).size.width;

    return SongPage(
      controller: _controller,
      title: widget.artist.name,
      subtitle: generateSubtitle(
        type: "Artist",
        numSongs: widget.artist.numSongs,
      ),
      hero: Hero(
        tag: widget.artist.name,
        child: widget.artist.images.length == 4
            ? Mozaic(widget.artist.images, screenWidth)
            : Image.file(
                File(widget.artist.images[0]),
                height: screenWidth,
                width: screenWidth,
                fit: BoxFit.cover,
              ),
      ),
      songs: _songs,
    );
  }
}
