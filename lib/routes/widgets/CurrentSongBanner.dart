import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music/bloc/queue_bloc.dart';

import './PlayPause.dart';

class CurrentSongBanner extends StatefulWidget {
  @override
  _CurrentSongBannerState createState() => _CurrentSongBannerState();
}

class _CurrentSongBannerState extends State<CurrentSongBanner> {
  DragStartDetails _dragStartDetails;
  DragUpdateDetails _dragUpdateDetails;

  static final threshold = 75;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildChild(BuildContext context, QueueState state) {
    if (state is EmptyQueue) {
      return Container();
    } else if (state is PlayingQueue) {
      var song = state.song;
      var width = MediaQuery.of(context).size.width;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pushNamed('/player'),
        onVerticalDragStart: (dragStartDetails) {
          setState(() {
            _dragStartDetails = dragStartDetails;
          });
        },
        onVerticalDragUpdate: (dragUpdateDetails) {
          setState(() {
            _dragUpdateDetails = dragUpdateDetails;
          });
        },
        onVerticalDragEnd: (dragEndDetails) {
          var delta = _dragUpdateDetails.localPosition.dy -
              _dragStartDetails.localPosition.dy;

          if (-delta > threshold ||
              -dragEndDetails.velocity.pixelsPerSecond.dy > threshold) {
            Navigator.of(context).pushNamed('/player');
          } else if (delta > 40 ||
              dragEndDetails.velocity.pixelsPerSecond.dy > 40) {
            BlocProvider.of<QueueBloc>(context).add(DequeueSongs());
          }
          setState(() {
            _dragStartDetails = null;
            _dragUpdateDetails = null;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[800], width: 1)),
          ),
          padding: EdgeInsets.all(10),
          child: Material(
            color: Theme.of(context).backgroundColor,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width / 3,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Hero(
                          tag: '${song.albumId}-player',
                          child: Image.file(
                            File(song.thumbnail),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 0.7 * width,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                  ],
                ),
                PlayPause(),
              ],
            ),
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
        double height = (state is EmptyQueue) ? 0 : 57;

        double transform = 0;

        if (_dragStartDetails != null && _dragUpdateDetails != null) {
          var delta = _dragUpdateDetails.localPosition.dy -
              _dragStartDetails.localPosition.dy;

          if (delta > 0) {
            transform = delta * 5.7 / 4;
          }

          if (delta < 0) {
            height += (delta < -120 ? 120 : -delta) * 5.7 / 4;
          }
        }

        return Transform.translate(
          offset: Offset(0, transform),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            color: Theme.of(context).backgroundColor,
            width: MediaQuery.of(context).size.width,
            height: height,
            child: _buildChild(context, state),
          ),
        );
      },
    );
  }
}
