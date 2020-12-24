import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music/global_providers/audio_player.dart';
import 'package:music/helpers/displace.dart';
import 'package:music/helpers/formatLength.dart';
import 'package:music/bloc/queue_bloc.dart';

import './widgets/SongList.dart';
import './CurrentSongPageWidgets/HeaderImage.dart';
import './CurrentSongPageWidgets/ControlBar.dart';

class CurrentSongPage extends StatefulWidget {
  @override
  _CurrentSongPageState createState() => _CurrentSongPageState();
}

class _CurrentSongPageState extends State<CurrentSongPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        if (state is EmptyQueue) {
          Navigator.of(context).pop();
        } else if (state is PlayingQueue) {
          var song = state.song;
          var width10 = MediaQuery.of(context).size.width / 10;

          return Material(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                HeaderImage(
                  song: song,
                ),
                SizedBox(
                  width: width10 * 8,
                  child: AudioPlayerBuilder.currentPosition(
                      context: context,
                      builder: (context, duration) {
                        var time = formatTime(duration, song.length);

                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(time.first),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: song.length.toDouble(),
                                onChanged: (double value) {
                                  AudioPlayerProvider.getPlayer(context)
                                      .seek(value.toInt());
                                },
                                value: duration.toDouble(),
                                inactiveColor:
                                    Theme.of(context).colorScheme.secondary,
                                activeColor: Theme.of(context).accentColor,
                              ),
                            ),
                            Text(time.second),
                          ],
                        );
                      }),
                ),
                ControlBar(
                  song: song,
                  shuffled: state.shuffled,
                  loop: state.loop,
                ),
                SizedBox(height: width10 / 2),
                SizedBox(
                  width: 8 * width10,
                  child: Text(
                    'Queue',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    child: SongList(
                      songs: displaceWithoutIndex(state.songs, state.index),
                      onClick: (song, index) {
                        // index is relative
                        BlocProvider.of<QueueBloc>(context).add(JumpToSong(
                          (state.index + index + 1) % state.songs.length,
                        ));
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
