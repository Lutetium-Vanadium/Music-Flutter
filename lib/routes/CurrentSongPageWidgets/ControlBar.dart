import 'package:Music/routes/CurrentSongPageWidgets/disable.dart';
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:Music/CustomIcons.dart";
import "package:Music/bloc/queue_bloc.dart";

class ControlBar extends StatefulWidget {
  final Disable disable;

  ControlBar({this.disable});

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

    var disablePrev =
        widget.disable == Disable.Both || widget.disable == Disable.Previous;
    var disableNext =
        widget.disable == Disable.Both || widget.disable == Disable.Next;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: width10 * 1.75),
      child: Material(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(CustomIcons.shuffle),
              color: false
                  ? Theme.of(context).accentColor
                  : Colors.white, // TODO shuffle
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.fast_rewind),
              disabledColor: Colors.grey[400],
              onPressed: disablePrev
                  ? null
                  : () {
                      if (disablePrev) return;
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
              onPressed: disableNext
                  ? null
                  : () {
                      if (disableNext) return;
                      BlocProvider.of<QueueBloc>(context).add(NextSong());
                    },
            ),
            IconButton(
              icon: Icon(CustomIcons.loop),
              color: false
                  ? Theme.of(context).accentColor
                  : Colors.white, // TODO loop
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
