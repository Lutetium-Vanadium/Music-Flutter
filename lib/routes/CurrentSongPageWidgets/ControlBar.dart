import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:Music/models/models.dart";
import "package:Music/CustomIcons.dart";
import "package:Music/bloc/queue_bloc.dart";

class ControlBar extends StatefulWidget {
  final SongData song;
  final bool shuffled;

  ControlBar({@required this.song, this.shuffled = false});

  @override
  _ControlBarState createState() => _ControlBarState();
}

class _ControlBarState extends State<ControlBar>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    const dur = Duration(milliseconds: 250);

    _controller = AnimationController(
      reverseDuration: dur,
      duration: dur,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.width / 10;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: width10 * 0.9),
      child: Material(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.playlist_add),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(CustomIcons.shuffle),
              color: widget.shuffled
                  ? Theme.of(context).accentColor
                  : Colors.white,
              onPressed: () {
                BlocProvider.of<QueueBloc>(context).add(ShuffleSongs());
              },
            ),
            IconButton(
              icon: Icon(Icons.fast_rewind),
              disabledColor: Colors.grey[400],
              onPressed: () {
                BlocProvider.of<QueueBloc>(context).add(PrevSong());
              },
            ),
            IconButton(
              icon: AnimatedIcon(
                icon: AnimatedIcons.pause_play,
                progress: _controller,
              ),
              onPressed: () {
                // TODO proper play pause
                if (_controller.value == 0) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.fast_forward),
              disabledColor: Colors.grey[400],
              onPressed: () {
                BlocProvider.of<QueueBloc>(context).add(NextSong());
              },
            ),
            IconButton(
              icon: Icon(CustomIcons.loop),
              color: Colors.white, // TODO loop
              onPressed: () {},
            ),
            IconButton(
              icon: widget.song.liked
                  ? Icon(Icons.favorite, color: Colors.red[900])
                  : Icon(Icons.favorite_border),
              onPressed: () {
                BlocProvider.of<QueueBloc>(context)
                    .add(ToggleLikedSong(widget.song));
              },
            ),
          ],
        ),
      ),
    );
  }
}
