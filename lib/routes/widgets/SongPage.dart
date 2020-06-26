import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:Music/bloc/queue_bloc.dart";
import "package:Music/helpers/displace.dart";
import "package:Music/constants.dart";
import "package:Music/models/models.dart";

import "./SongView.dart";
import "./CurrentSongBanner.dart";

class SongPage extends StatelessWidget {
  final AnimationController controller;
  final List<SongData> songs;
  final String title;
  final String subtitle;
  final Hero hero;

  const SongPage({
    Key key,
    @required this.controller,
    @required this.title,
    @required this.subtitle,
    @required this.hero,
    @required this.songs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      persistentFooterButtons: <Widget>[
        CurrentSongBanner(),
      ],
      body: Column(
        children: <Widget>[
          HeaderImage(
            hero: hero,
            subtitle: subtitle,
            title: title,
            controller: controller,
          ),
          SizedBox(height: 30),
          Expanded(
            child: AnimatedSongView(
              controller: controller,
              delay: 0.5,
              length: 0.5,
              songs: songs,
              onClick: (song, index) {
                BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
                  songs: displace(songs, index),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderImage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Hero hero;
  final AnimationController controller;
  final Animation<double> _animation1;
  final Animation<double> _animation2;

  HeaderImage({
    Key key,
    @required this.controller,
    @required this.title,
    @required this.subtitle,
    @required this.hero,
  })  : _animation1 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(0.0, 0.5, curve: Curves.easeOutCubic),
        )),
        _animation2 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(0.25, 0.75, curve: Curves.easeOutCubic),
        )),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: controller,
      child: hero,
      builder: (_, child) => Stack(
        overflow: Overflow.visible,
        children: [
          child,
          Opacity(
            opacity: _animation1.value,
            child: Container(
              width: screenWidth,
              height: screenWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).backgroundColor.withOpacity(0.2),
                    Theme.of(context).backgroundColor.withOpacity(0.2),
                    Theme.of(context).backgroundColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: _animation2.value,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ),
          Opacity(
            opacity: _animation1.value,
            child: SizedBox(
              height: screenWidth,
              width: screenWidth,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: screenWidth / 4,
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: 0.8 * screenWidth),
                      child: Text(
                        title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -2 * rem,
            left: 0.2 * screenWidth,
            width: 0.6 * screenWidth,
            child: Opacity(
              opacity: _animation2.value,
              child: ButtonBar(
                buttonHeight: 2.5 * rem,
                buttonMinWidth: 0.25 * screenWidth,
                alignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.25 * rem)),
                    color: Theme.of(context).buttonColor,
                    onPressed: () {},
                    child: Text("Play All"),
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.25 * rem)),
                    color: Theme.of(context).buttonColor,
                    onPressed: () {},
                    child: Text("Play Random"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
