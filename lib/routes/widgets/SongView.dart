import "dart:io";
import "package:flutter/material.dart";

import "package:Music/constants.dart";
import "package:Music/models/models.dart";

import "./Song.dart";

class SongView extends StatelessWidget {
  final List<SongMetadata> songs;
  final void Function(SongMetadata, int) onClick;
  final IconData iconData;
  final bool isNetwork;
  final bool showFocusedMenuItems;
  final Widget before;

  SongView({
    @required this.songs,
    this.onClick,
    this.iconData,
    this.before,
    this.isNetwork = false,
    this.showFocusedMenuItems = true,
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
            color: Theme.of(context).buttonColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 5,
          ),
        ),
      );
    }

    if (songs.length == 0) {
      return Center(
        child: Text(
          isNetwork ? "No Results." : "Empty.",
          style: Theme.of(context).textTheme.headline4,
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        FocusScope.of(notification.context).unfocus();
        return true;
      },
      child: ListView.builder(
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
          return Song(
            iconData: iconData,
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
                          "$imgs/music_symbol.png",
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
      ),
    );
  }
}

class AnimatedSongView extends StatelessWidget {
  final List<SongMetadata> songs;
  final void Function(SongMetadata, int) onClick;
  final IconData iconData;
  final bool isNetwork;
  final Widget before;

  final double delay;
  final double length;
  final AnimationController controller;
  final Animation<double> _opacity;
  final Animation<Offset> _translate;

  AnimatedSongView({
    Key key,
    @required this.controller,
    this.delay = 0,
    this.length = 1,
    @required this.songs,
    this.onClick,
    this.iconData,
    this.before,
    this.isNetwork = false,
  })  : _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(delay, delay + length, curve: Curves.easeOutCubic),
        )),
        _translate =
            Tween<Offset>(begin: Offset(0, -1.5 * rem), end: Offset.zero)
                .animate(CurvedAnimation(
          parent: controller,
          curve: Interval(delay, delay + length, curve: Curves.easeOutCubic),
        )),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: SongView(
        songs: songs,
        onClick: onClick,
        iconData: iconData,
        before: before,
        isNetwork: isNetwork,
      ),
      builder: (_, child) => Transform.translate(
        offset: _translate.value,
        child: Opacity(
          opacity: _opacity.value,
          child: child,
        ),
      ),
    );
  }
}
