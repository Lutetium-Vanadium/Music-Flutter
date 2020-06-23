import "package:Music/bloc/notification_bloc.dart";
import "package:flutter/material.dart";

import "package:Music/helpers/db.dart";
import "package:Music/models/models.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../widgets/SongView.dart";

class Music extends StatefulWidget {
  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  List<SongData> songs = [];

  @override
  void initState() {
    super.initState();

    getSongs();
  }

  Future<void> getSongs() async {
    var db = await getDB();

    var allSongs = SongData.fromMapArray(
      await db.query(Tables.Songs, orderBy: "LOWER(title), title"),
    );

    if (!mounted) return;

    setState(() {
      songs = allSongs;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return BlocListener<NotificationBloc, NotificationState>(
      listener: (_, state) {
        if (state is DownloadedNotification) {
          getSongs();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: width10 / 4 * 2, top: 30, bottom: 7),
            child:
                Text("My Music", style: Theme.of(context).textTheme.headline3),
          ),
          Expanded(
            child: SongView(
              songs: songs,
              isLocal: true,
              onClick: (song, _) {
                print(song);
              },
            ),
          ),
        ],
      ),
    );
  }
}
