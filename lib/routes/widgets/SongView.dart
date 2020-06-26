import "dart:io";
import "package:flutter/material.dart";
import "package:focused_menu/modals.dart";
import "package:focused_menu/focused_menu.dart";

import "package:Music/CustomSplashFactory.dart";
import "package:Music/helpers/formatLength.dart";
import "package:Music/constants.dart";
import "package:Music/models/models.dart";

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

          return Container(
            margin: EdgeInsets.symmetric(
              vertical: 0.6 * rem,
              horizontal: 1.2 * rem,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rem / 2),
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Material(
              color: Colors.transparent,
              child: !showFocusedMenuItems
                  ? _buildSongDetails(context, song, index)
                  : FocusedMenuHolder(
                      menuItems: [
                        FocusedMenuItem(
                          onPressed: () => onClick(song, index),
                          title: Text("Play"),
                          trailingIcon: Icon(Icons.play_arrow),
                          backgroundColor: Colors.transparent,
                        ),
                        FocusedMenuItem(
                          onPressed: () {},
                          title: Text("Like"),
                          trailingIcon: Icon(Icons.favorite_border),
                          backgroundColor: Colors.transparent,
                        ),
                        FocusedMenuItem(
                          onPressed: () {},
                          title: Text("Delete",
                              style: TextStyle(color: Colors.red)),
                          trailingIcon: Icon(Icons.delete, color: Colors.red),
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                      child: _buildSongDetails(context, song, index),
                      onPressed: () {},
                      animateMenuItems: false,
                      blurSize: 5,
                      menuBoxDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Theme.of(context).canvasColor.withOpacity(0.69),
                      ),
                      blurBackgroundColor: Colors.transparent,
                      duration: Duration(milliseconds: 300),
                      menuWidth: 150,
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSongDetails(BuildContext context, SongData song, int index) {
    return InkWell(
      onTap: () {
        if (onClick != null) {
          onClick(song, index);
        }
      },
      splashFactory: CustomSplashFactory(),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(rem / 2),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0.6 * rem,
          horizontal: 1.2 * rem,
        ),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0.6 * rem),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0.4 * rem),
                child: isNetwork
                    ? Image.network(
                        song.thumbnail,
                        fit: BoxFit.scaleDown,
                        width: 4 * rem,
                        height: 4 * rem,
                        frameBuilder:
                            (ctx, widget, frame, synchronouslyLoaded) {
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
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: rem, right: 1.5 * rem),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      song.title,
                      style: Theme.of(context).textTheme.bodyText1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0.5 * rem, left: 0.8 * rem),
                      child: Text(
                        song.artist,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(formatLength(song.length)),
            Padding(
              padding: iconData == null
                  ? EdgeInsets.all(0)
                  : EdgeInsets.only(left: 13, right: 3),
              child: Icon(
                iconData,
                size: 1.5 * rem,
              ),
            ),
          ],
        ),
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
