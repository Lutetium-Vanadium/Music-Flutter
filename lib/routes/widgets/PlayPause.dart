import "package:flutter/material.dart";

import "package:Music/global_providers/audio_player.dart";

class PlayPause extends StatefulWidget {
  @override
  _PlayPauseState createState() => _PlayPauseState();
}

class _PlayPauseState extends State<PlayPause>
    with SingleTickerProviderStateMixin {
  bool _playing = true;
  AnimationController _controller;

  @override
  void initState() {
    const dur = Duration(milliseconds: 250);

    _controller = AnimationController(
      reverseDuration: dur,
      duration: dur,
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudioPlayerBuilder.isPlaying(
      context: context,
      builder: (context, isPlaying) {
        if (isPlaying != _playing) {
          if (_playing) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
          _playing = !_playing;
        }

        return IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.pause_play,
            progress: _controller,
          ),
          onPressed: () {
            AudioPlayerProvider.getPlayer(context).togglePlay();
          },
        );
      },
    );
  }
}
