import 'package:Music/helpers/updateAlbum.dart';
import 'package:Music/helpers/db.dart';
import 'package:Music/helpers/downloader.dart';
import 'package:Music/helpers/getYoutubeDetails.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';

import "../dataClasses.dart";
import '../constants.dart';
import '../input.dart';
import "../helpers/napster.dart" as napster;
import './shared/SongView.dart';

class Search extends StatefulWidget {
  final String intitalQuery;

  Search(this.intitalQuery);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<NapsterSongData> _results;
  TextEditingController _textController;

  void goHome() {
    Navigator.of(context).pushNamed("/");
  }

  void search(String query) async {
    if (query.length == 0) {
      Navigator.of(context).pushNamed("/");
    } else if (query.length % 2 == 1) {
      var res = await napster.search(query);
      setState(() {
        _results = res;
      });
    }
  }

  void download(NapsterSongData songData, int index) async {
    print(songData);

    var data = await getYoutubeDetails(songData);

    if (data == null) return;

    var filename = songData.title + ".mp3";
    var albumId = songData.albumId;

    print("Downloading ${songData.title}");
    var downloadFuture = downloadSong(data.id, filename);
    var updateAlbumFuture = updateAlbum(albumId, songData.artist);

    var root = await getApplicationDocumentsDirectory();

    var song = Song(
      albumId: albumId,
      artist: songData.artist,
      filePath: "${root.path}/songs/$filename",
      length: data.length,
      liked: false,
      numListens: 0,
      thumbnail: "${root.path}/album_images/$albumId.jpg",
      title: songData.title,
    );

    var db = await getDB();

    await db.insert(Tables.Songs, Song.toMap(song));

    await Future.wait([downloadFuture, updateAlbumFuture]);

    await db.close();
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.intitalQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).backgroundColor,
        textTheme: Theme.of(context).textTheme,
        leading: GestureDetector(
          onTap: Navigator.of(context).pop,
          child: Icon(CupertinoIcons.back),
        ),
        title: Hero(
          tag: "navbar-title",
          child: GestureDetector(
            onTap: goHome,
            child: Row(
              children: <Widget>[
                Image(
                  image: AssetImage("$imgs/icon.png"),
                  fit: BoxFit.scaleDown,
                  height: 2.5 * rem,
                ),
                Text(
                  "Music",
                  style: TextStyle(color: Colors.white, fontSize: 1.5 * rem),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            width: MediaQuery.of(context).size.width / 2 - 30,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
            child: Row(
              children: <Widget>[
                Input(
                  placeholder: "Download",
                  controller: _textController,
                  autofocus: true,
                  onChange: search,
                ),
                Icon(Icons.search),
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
        primary: true,
      ),
      body: SongView(
        songs: _results,
        onClick: download,
      ),
    );
  }
}
