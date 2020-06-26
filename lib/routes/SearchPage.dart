import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../bloc/notification_bloc.dart";
import "../models/models.dart";
import "../constants.dart";
import "../helpers/napster.dart" as napster;
import "./widgets/Input.dart";
import "./widgets/SongView.dart";
import "./widgets/CurrentSongBanner.dart";

class SearchPage extends StatefulWidget {
  final String intitalQuery;

  SearchPage(this.intitalQuery);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<NapsterSongData> _results;
  TextEditingController _textController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void goHome() {
    Navigator.of(context).pop();
  }

  void search(String query) async {
    if (query.length == 0) {
      Navigator.of(context).pop();
    } else if (query.length % 2 == 1) {
      var res = await napster.search(query);
      if (!mounted) return;
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
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
      persistentFooterButtons: <Widget>[
        CurrentSongBanner(),
      ],
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SongView(
          songs: _results,
          isNetwork: true,
          onClick: (songData, index) {
            BlocProvider.of<NotificationBloc>(context)
                .add(DownloadSong(songData));
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Preparing to download ${songData.title}"),
            ));
          },
        ),
      ),
    );
  }
}
