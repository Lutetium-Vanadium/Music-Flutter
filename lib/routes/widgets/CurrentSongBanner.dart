import "dart:io";
import "package:assets_audio_player/assets_audio_player.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:Music/constants.dart";
import "package:Music/bloc/queue_bloc.dart";

import "./PlayPause.dart";

class CurrentSongBanner extends StatefulWidget {
  @override
  _CurrentSongBannerState createState() => _CurrentSongBannerState();
}

class _CurrentSongBannerState extends State<CurrentSongBanner> {
  AssetsAudioPlayer audioPlayer;
  DragStartDetails _dragStartDetails;
  DragUpdateDetails _dragUpdateDetails;

  static final threshold = 75;

  @override
  void initState() {
    super.initState();

    audioPlayer = AssetsAudioPlayer.withId(playerId);
  }

  Widget _buildChild(BuildContext context, QueueState state) {
    if (state is EmptyQueue) {
      return null;
    } else if (state is PlayingQueue) {
      var song = state.song;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pushNamed("/player"),
        onVerticalDragStart: (dragStartDetails) {
          _dragStartDetails = dragStartDetails;
        },
        onVerticalDragUpdate: (dragUpdateDetails) {
          _dragUpdateDetails = dragUpdateDetails;
        },
        onVerticalDragEnd: (dragEndDetails) {
          var delta = _dragUpdateDetails.localPosition.dy -
              _dragStartDetails.localPosition.dy;
          if (-delta > threshold ||
              -dragEndDetails.velocity.pixelsPerSecond.dy > threshold) {
            Navigator.of(context).pushNamed("/player");
          } else if (delta > threshold / 3 ||
              dragEndDetails.velocity.pixelsPerSecond.dy > threshold / 3) {
            BlocProvider.of<QueueBloc>(context).add(DequeueSongs());
          }
        },
        child: Material(
          color: Theme.of(context).backgroundColor,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Hero(
                      tag: "${song.albumId}-player",
                      child: Image.file(
                        File(song.thumbnail),
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ],
              ),
              PlayPause(audioPlayer),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        double height = (state is EmptyQueue) ? 0 : 50;

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          color: Theme.of(context).backgroundColor,
          width: MediaQuery.of(context).size.width,
          height: height,
          child: _buildChild(context, state),
        );
      },
    );
  }
}
