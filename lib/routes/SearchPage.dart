import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music/global_providers/database.dart';
import 'package:music/bloc/data_bloc.dart';
import 'package:music/models/models.dart';
import 'package:music/constants.dart';
import 'package:music/helpers/napster.dart' as napster;
import 'package:music/helpers/youtube.dart' as youtube;
import './widgets/Input.dart';
import './widgets/SongList.dart';
import './widgets/CurrentSongBanner.dart';

class SearchPage extends StatefulWidget {
  final String intitalQuery;

  SearchPage(this.intitalQuery);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<SongMetadata> _results;
  bool _isSearching = false;
  bool _errored = false;
  TextEditingController _textController;
  var _titles = Set<String>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> search(String query) async {
    if (!_isSearching) {
      _isSearching = true;

      var napsterRes = await napster.search(query);
      var napsterErrored = napsterRes == null;
      List<SongMetadata> res = [...napsterRes] ?? [];

      var youtubeRes = await youtube.getSearchResults(query);
      var youtubeErrored = youtubeRes == null;
      res.addAll(youtubeRes ?? []);

      res.removeWhere((song) => _titles.contains(song.title));

      setState(() {
        _errored = napsterErrored && youtubeErrored;
        _results = res;
        _isSearching = false;
      });
    }
  }

  Future<void> _getTitles() async {
    var titles =
        (await DatabaseProvider.getDB(context).getSongs()).map((s) => s.title);

    if (!mounted) return;
    setState(() {
      _titles = titles.toSet();
    });
  }

  @override
  void initState() {
    _getTitles();
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
        leading: GestureDetector(
          onTap: Navigator.of(context).pop,
          child: Icon(CupertinoIcons.back),
        ),
        title: Hero(
          tag: 'navbar-title',
          child: GestureDetector(
            onTap: Navigator.of(context).pop,
            child: Row(
              children: <Widget>[
                Image(
                  image: AssetImage('$imgs/icon.png'),
                  fit: BoxFit.scaleDown,
                  height: 2.5 * rem,
                ),
                Text(
                  'Music',
                  style: Theme.of(context).textTheme.headline6,
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
                  placeholder: 'Download',
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
      bottomNavigationBar: CurrentSongBanner(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: _errored
            ? Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    Text(
                      ' Error',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              )
            : SongList(
                songs: _results,
                isNetwork: true,
                showFocusedMenuItems: false,
                onClick: (songData, index) {
                  BlocProvider.of<DataBloc>(context)
                      .add(DownloadSong(songData));
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Preparing to download ${songData.title}.'),
                  ));
                },
                getIcon: (index) {
                  var song = _results[index];

                  String albumId =
                      song is NapsterSongData ? song.albumId : 'ytb';

                  return BlocBuilder<DataBloc, DataState>(
                    builder: (context, state) {
                      if (state is ProgressNotification &&
                          state.id == (song.title + albumId)) {
                        return SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).colorScheme.secondaryVariant),
                            value: state.percentage,
                            strokeWidth: 2,
                          ),
                        );
                      } else {
                        return Image.asset(
                          '$imgs/download.png',
                          height: 1.3 * rem,
                        );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
