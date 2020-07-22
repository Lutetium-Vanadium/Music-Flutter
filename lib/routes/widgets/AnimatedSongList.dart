import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Music/bloc/queue_bloc.dart';
import 'package:Music/helpers/displace.dart';
import 'package:Music/constants.dart';
import 'package:Music/models/models.dart';

import './SongView.dart';

class AnimatedSongList extends StatelessWidget {
  final List<SongMetadata> songs;
  final void Function(SongMetadata, int) onClick;
  final Widget Function(int) getIcon;
  final bool isNetwork;
  final Widget before;

  final double delay;
  final double length;
  final AnimationController controller;
  final Animation<double> _opacity;

  AnimatedSongList({
    Key key,
    @required this.controller,
    this.delay = 0,
    this.length = 1,
    @required this.songs,
    this.onClick,
    this.getIcon,
    this.before,
    this.isNetwork = false,
  })  : _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(delay, delay + length, curve: Curves.linear),
        )),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFadeTransition(
      opacity: _opacity,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            var song = songs[index];
            return SongView(
              song: song,
              onClick: () {
                BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
                  songs: displace(songs, index),
                ));
              },
              showFocusedMenuItems: true,
              image: Image.file(
                File(song.thumbnail),
                fit: BoxFit.scaleDown,
                width: 4 * rem,
                height: 4 * rem,
              ),
              icon: getIcon == null ? null : getIcon(index),
            );
          },
          childCount: songs.length,
        ),
      ),
    );
  }
}
