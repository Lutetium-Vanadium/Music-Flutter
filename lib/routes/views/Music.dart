import "dart:math";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:Music/constants.dart";
import "package:Music/bloc/notification_bloc.dart";
import "package:Music/bloc/queue_bloc.dart";
import "package:Music/helpers/displace.dart";
import "package:Music/helpers/db.dart";
import "package:Music/models/models.dart";
import "../widgets/SongList.dart";

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

    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationBloc, NotificationState>(
          listener: (_, state) {
            if (state is DownloadedNotification || state is UpdateData) {
              getSongs();
            }
          },
        ),
        BlocListener<QueueBloc, QueueState>(
          listener: (context, state) {
            if (state.updateData) {
              getSongs();
            }
          },
        ),
      ],
      child: SongList(
        before: Padding(
          padding: EdgeInsets.only(
            left: width10 / 2,
            right: width10 / 2,
            top: 30,
            bottom: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("My Music", style: Theme.of(context).textTheme.headline3),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.25 * rem)),
                color: Theme.of(context).buttonColor,
                onPressed: () {
                  var random = Random();
                  BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
                      songs: songs,
                      index: random.nextInt(songs.length),
                      shuffle: true));
                },
                child: Text("Play Random"),
              ),
            ],
          ),
        ),
        songs: songs,
        onClick: (song, index) {
          BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
            songs: displace(songs, index),
          ));
        },
      ),
    );
  }
}
