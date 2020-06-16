import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";

import '../CustomIcons.dart';
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
  List<NapsterSongData> _results = [];
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

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.intitalQuery);
  }

  @override
  Widget build(BuildContext context) {
    if (_results.length > 0) {
      print("TITLE1: ${_results.first.title}");
    }

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
            child: Hero(
              tag: "navbar-search",
              child: Row(
                children: <Widget>[
                  Input(
                    placeholder: "Download",
                    controller: _textController,
                    autofocus: true,
                    onChange: search,
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      search(_textController.text);
                    },
                  ),
                ],
              ),
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
        onClick: (song, index) {
          print("$index: $song");
        },
        // iconData: Icons.file_download
      ),
    );
  }
}
