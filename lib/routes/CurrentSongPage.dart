import "dart:io";
import "package:Music/helpers/displace.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:palette_generator/palette_generator.dart";

import "package:Music/helpers/formatLength.dart";
import "package:Music/bloc/queue_bloc.dart";

import "./widgets/SongList.dart";
import "./CurrentSongPageWidgets/HeaderImage.dart";
import "./CurrentSongPageWidgets/ControlBar.dart";

class CurrentSongPage extends StatefulWidget {
  @override
  _CurrentSongPageState createState() => _CurrentSongPageState();
}

class _CurrentSongPageState extends State<CurrentSongPage> {
  String _albumId;
  Color _colour = Colors.transparent;

  Future<Color> generateColour(String path) async {
    var paletteGenerator =
        await PaletteGenerator.fromImageProvider(FileImage(File(path)));

    if (paletteGenerator.dominantColor != null) {
      return paletteGenerator.dominantColor.color;
    }
    if (paletteGenerator.lightMutedColor != null) {
      return paletteGenerator.lightMutedColor.color;
    }
    if (paletteGenerator.lightVibrantColor != null) {
      return paletteGenerator.lightVibrantColor.color;
    }
    if (paletteGenerator.mutedColor != null) {
      return paletteGenerator.mutedColor.color;
    }
    if (paletteGenerator.vibrantColor != null) {
      return paletteGenerator.vibrantColor.color;
    }
    if (paletteGenerator.darkMutedColor != null) {
      return paletteGenerator.darkMutedColor.color;
    }
    if (paletteGenerator.darkVibrantColor != null) {
      return paletteGenerator.darkVibrantColor.color;
    }

    return Color(0xFF323232);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        if (state is EmptyQueue) {
          Navigator.of(context).pop();
          throw "EmptyQueue in CurrentSongPage.";
        } else if (state is PlayingQueue) {
          var song = state.song;
          var width10 = MediaQuery.of(context).size.width / 10;

          if (_albumId != song.albumId) {
            generateColour(song.thumbnail).then(
              (colour) {
                if (mounted) {
                  setState(() {
                    _colour = colour;
                    _albumId = song.albumId;
                  });
                }
              },
            );
          }

          var time = formatTime(song.length ~/ 3, song.length);

          return Material(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                HeaderImage(
                  colour: _colour,
                  song: song,
                ),
                SizedBox(
                  width: width10 * 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(time.first),
                      Expanded(
                        child: Slider(
                          min: 0,
                          max: song.length.toDouble(),
                          onChanged:
                              (double value) {}, // TODO implement scrubbing
                          value: song.length / 3, // TODO show correct value
                          inactiveColor:
                              Theme.of(context).colorScheme.secondary,
                          activeColor: Theme.of(context).accentColor,
                        ),
                      ),
                      Text(time.second),
                    ],
                  ),
                ),
                ControlBar(song: song, shuffled: state.shuffled),
                SizedBox(height: width10 / 2),
                SizedBox(
                  width: 8 * width10,
                  child: Text(
                    "Queue",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                Expanded(
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
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
