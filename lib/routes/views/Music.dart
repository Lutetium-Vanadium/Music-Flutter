import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music/global_providers/database.dart';
import 'package:music/constants.dart';
import 'package:music/bloc/data_bloc.dart';
import 'package:music/bloc/queue_bloc.dart';
import 'package:music/helpers/displace.dart';
import 'package:music/models/models.dart';
import '../widgets/SongList.dart';

class Music extends StatefulWidget {
  @override
  _MusicState createState() => _MusicState();
}

class _MusicState extends State<Music> {
  List<SongData> _songs = [];

  @override
  void initState() {
    super.initState();

    getSongs();
  }

  Future<void> getSongs() async {
    var songs = await DatabaseProvider.getDB(context).getSongs();

    if (!mounted) return;

    setState(() {
      _songs = songs.length > 0 ? songs : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return MultiBlocListener(
      listeners: [
        BlocListener<DataBloc, DataState>(
          listener: (_, state) {
            if (state is UpdateData) {
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
      child: _songs == null
          ? Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: width10 / 2, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'My Music',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'No songs are downloaded.\n\n',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      TextSpan(
                        text:
                            'Download songs by searching through the above Search Box.\n',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ]),
                  ),
                ],
              ),
            )
          : SongList(
              showEmptyText: false,
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
                    Text('My Music',
                        style: Theme.of(context).textTheme.headline3),
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.25 * rem),
                        )),
                      ),
                      onPressed: () {
                        var random = Random();
                        BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
                          songs: _songs,
                          index: random.nextInt(_songs.length),
                          shuffle: true,
                        ));
                      },
                      child: Text('Play Random'),
                    ),
                  ],
                ),
              ),
              songs: _songs,
              onClick: (song, index) {
                BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
                  songs: displace(_songs, index),
                ));
              },
            ),
    );
  }
}
