import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music/bloc/data_bloc.dart';
import 'package:music/bloc/queue_bloc.dart';
import 'package:music/helpers/displace.dart';
import 'package:music/constants.dart';
import 'package:music/models/models.dart';

import './CurrentSongBanner.dart';
import './AnimatedSongList.dart';
import './showConfirm.dart';

class SongPage extends StatefulWidget {
  final AnimationController controller;
  final List<SongData> songs;
  final String title;
  final String subtitle;
  final CustomAlbumData customAlbum;

  final Hero hero;

  SongPage({
    Key key,
    @required this.controller,
    @required this.title,
    @required this.subtitle,
    @required this.hero,
    @required this.songs,
    this.customAlbum,
  }) : super(key: key);

  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      bottomNavigationBar: CurrentSongBanner(),
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          CustomAppBar(
            scrollController: _scrollController,
            hero: widget.hero,
            subtitle: widget.subtitle,
            title: widget.title,
            animationController: widget.controller,
            songs: widget.songs,
            customAlbum: widget.customAlbum,
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                var tween = Tween<double>(begin: 20, end: 40).animate(
                  CurvedAnimation(
                    parent: widget.controller,
                    curve: Interval(0.5, 1, curve: Curves.easeOutCubic),
                  ),
                );
                return SizedBox(height: tween.value);
              },
            ),
          ),
          AnimatedSongList(
            controller: widget.controller,
            delay: 0.5,
            length: 0.5,
            songs: widget.songs,
            onClick: (song, index) {
              BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
                songs: displace(widget.songs, index),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget {
  final String title;
  final String subtitle;
  final Hero hero;
  final AnimationController animationController;
  final List<SongData> songs;
  final ScrollController scrollController;
  final CustomAlbumData customAlbum;

  CustomAppBar({
    Key key,
    @required this.animationController,
    @required this.title,
    @required this.subtitle,
    @required this.hero,
    @required this.songs,
    @required this.scrollController,
    this.customAlbum,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  double _textOpacity = 0;

  void _scrollListener() {
    var screenWidth = MediaQuery.of(context).size.width;

    if (widget.scrollController.hasClients) {
      var scrollPercent = widget.scrollController.offset / screenWidth;
      var opacity = clamp(scrollPercent, 0.4, 0.6, from: 1, to: 0);
      if (opacity != _textOpacity) {
        setState(() {
          _textOpacity = opacity;
        });
      }
    } else {
      widget.scrollController.removeListener(_scrollListener);
    }
  }

  @override
  void initState() {
    widget.scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var statusBarHeight = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      expandedHeight: screenWidth - kToolbarHeight + statusBarHeight,
      // centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: Navigator.of(context).pop,
      ),
      title: Opacity(
        opacity: _textOpacity,
        child: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      actions: <Widget>[
        Opacity(
          opacity: _textOpacity,
          child: IconButton(
            tooltip: 'Play All',
            icon: Icon(Icons.play_arrow),
            onPressed: _textOpacity < 0.6
                ? null
                : () {
                    BlocProvider.of<QueueBloc>(context)
                        .add(EnqueueSongs(songs: widget.songs));
                  },
          ),
        ),
        ...(widget.customAlbum != null
            ? [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/select-songs',
                        arguments: widget.customAlbum);
                  },
                  tooltip: 'Edit Album',
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    if (await showConfirm(
                      context,
                      'Delete ${widget.customAlbum.name}',
                      'Are you sure you want to delete ${widget.customAlbum.name}?',
                    )) {
                      Navigator.of(context).pop();
                      BlocProvider.of<DataBloc>(context)
                          .add(DeleteCustomAlbum(widget.customAlbum.id));
                    }
                  },
                  color: Colors.red,
                  tooltip: 'Delete Album',
                ),
              ]
            : [])
      ],
      pinned: true,
      flexibleSpace: LayoutBuilder(builder: (context, constraints) {
        double percent = (constraints.maxHeight - kToolbarHeight) /
            (screenWidth - kToolbarHeight);

        return HeaderImage(
          controller: widget.animationController,
          hero: widget.hero,
          songs: widget.songs,
          subtitle: widget.subtitle,
          title: widget.title,
          percent: percent,
        );
      }),
    );
  }
}

class HeaderImage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Hero hero;
  final AnimationController controller;
  final List<SongData> songs;
  final double percent;

  final Animation<double> _animation1;
  final Animation<double> _animation2;

  HeaderImage({
    Key key,
    @required this.controller,
    @required this.title,
    @required this.subtitle,
    @required this.hero,
    @required this.songs,
    @required this.percent,
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
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
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
                      Theme.of(context).backgroundColor.withOpacity(0.3),
                      Theme.of(context).backgroundColor.withOpacity(0.3),
                      Theme.of(context).backgroundColor.withOpacity(
                          clamp(percent, 0.4, 0.7, from: 1, to: 0.3)),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: controller.isCompleted
                  ? clamp(percent, 0.4, 0.6)
                  : _animation1.value,
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
                        constraints:
                            BoxConstraints(maxWidth: 0.8 * screenWidth),
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
              bottom: _animation2.value * (-rem) - rem,
              left: 0.2 * screenWidth,
              width: 0.6 * screenWidth,
              child: Opacity(
                opacity: controller.isCompleted
                    ? clamp(percent, 0.6, 0.8)
                    : _animation2.value,
                child: ButtonBar(
                  buttonHeight: 2.5 * rem,
                  buttonMinWidth: 0.25 * screenWidth,
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.25 * rem),
                        )),
                      ),
                      onPressed: () {
                        BlocProvider.of<QueueBloc>(context)
                            .add(EnqueueSongs(songs: songs));
                      },
                      child: Text('Play All'),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.25 * rem),
                        )),
                      ),
                      onPressed: () {
                        var random = Random();
                        BlocProvider.of<QueueBloc>(context).add(EnqueueSongs(
                          songs: songs,
                          index: random.nextInt(songs.length),
                          shuffle: true,
                        ));
                      },
                      child: Text('Play Random'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

double clamp(double _percent, double start, double end,
    {double from = 0, double to = 1}) {
  double percent;

  if (_percent > end) {
    percent = 1;
  } else if (_percent < start) {
    percent = 0;
  } else {
    percent = (_percent - start) / (end - start);
  }

  if (from > to) {
    return from - (1 - percent) * (from - to);
  } else {
    return from + percent * (to - from);
  }
}
