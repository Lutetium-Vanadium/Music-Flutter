import 'dart:io';
import 'package:flutter/material.dart';

import 'package:music/constants.dart';
import 'package:music/models/models.dart';

import './SongView.dart';

class SongList extends StatelessWidget {
  final List<SongMetadata> songs;
  final void Function(SongMetadata, int) onClick;
  final Widget Function(int) getIcon;
  final bool isNetwork;
  final bool showFocusedMenuItems;
  final Widget before;
  final bool showEmptyText;

  SongList({
    @required this.songs,
    this.onClick,
    this.getIcon,
    this.before,
    this.isNetwork = false,
    this.showFocusedMenuItems = true,
    this.showEmptyText = true,
  });

  @override
  Widget build(BuildContext context) {
    if (songs == null) {
      return Center(
        child: Container(
          width: 50,
          height: 50,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryVariant,
            borderRadius: BorderRadius.circular(25),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
            strokeWidth: 5,
          ),
        ),
      );
    }

    if (songs.length == 0) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: showEmptyText
            ? Text(
                isNetwork ? 'No Results.' : 'Empty.',
                style: Theme.of(context).textTheme.headline4,
              )
            : Container(),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding:
          EdgeInsets.only(top: before == null ? rem / 2 : 0, bottom: 2 * rem),
      itemCount: before == null ? songs.length : songs.length + 2,
      itemBuilder: (context, _index) {
        var index = before == null ? _index : _index - 2;

        if (index == -2) {
          return before;
        } else if (index == -1) {
          return SizedBox(height: rem / 2);
        }

        var song = songs[index];
        return SongView(
          icon: getIcon == null ? null : getIcon(index),
          song: song,
          onClick: () {
            if (onClick != null) {
              onClick(song, index);
            }
          },
          showFocusedMenuItems: showFocusedMenuItems,
          image: isNetwork
              ? Image.network(
                  song.thumbnail,
                  fit: BoxFit.scaleDown,
                  width: 4 * rem,
                  height: 4 * rem,
                  frameBuilder: (ctx, widget, frame, synchronouslyLoaded) {
                    if (synchronouslyLoaded) {
                      return widget;
                    }

                    return AnimatedCrossFade(
                      firstChild: Image.asset(
                        '$imgs/music_symbol.png',
                        fit: BoxFit.scaleDown,
                        width: 4 * rem,
                        height: 4 * rem,
                      ),
                      secondChild: widget,
                      crossFadeState: frame == null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 400),
                    );
                  },
                )
              : Image.file(
                  File(song.thumbnail),
                  fit: BoxFit.scaleDown,
                  width: 4 * rem,
                  height: 4 * rem,
                ),
        );
      },
    );
  }
}
