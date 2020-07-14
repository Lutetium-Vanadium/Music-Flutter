import "dart:io";
import "dart:ui";
import "package:flutter/material.dart";

import "package:Music/models/song_data.dart";

class HeaderImage extends StatefulWidget {
  final SongData song;
  final Color colour;

  HeaderImage({this.song, this.colour});

  @override
  _HeaderImageState createState() => _HeaderImageState();
}

class _HeaderImageState extends State<HeaderImage> {
  DragStartDetails _dragStartDetails;
  DragUpdateDetails _dragUpdateDetails;

  static final threshold = 75;

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.width / 10;

    return Stack(
      children: [
        GestureDetector(
          onVerticalDragStart: (dragStartDetails) {
            _dragStartDetails = dragStartDetails;
          },
          onVerticalDragUpdate: (dragUpdateDetails) {
            _dragUpdateDetails = dragUpdateDetails;
          },
          onVerticalDragCancel: () {
            _dragStartDetails = null;
            _dragUpdateDetails = null;
          },
          onVerticalDragEnd: (dragEndDetails) {
            var delta = _dragUpdateDetails.localPosition.dy -
                _dragStartDetails.localPosition.dy;
            if (delta > threshold ||
                dragEndDetails.velocity.pixelsPerSecond.dy > threshold) {
              Navigator.of(context).pop();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Image.file(
                    File(widget.song.thumbnail),
                    width: width10 * 10,
                  ),
                ),
              ),
              Container(
                width: 10 * width10,
                height: 10 * width10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).backgroundColor.withOpacity(0.2),
                      Theme.of(context).backgroundColor.withOpacity(0.4),
                      Theme.of(context).backgroundColor.withOpacity(1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: width10,
                  right: width10,
                  top: 1.65 * width10,
                ),
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Hero(
                        tag: "${widget.song.albumId}-player",
                        child: Image.file(
                          File(widget.song.thumbnail),
                          height: width10 * 6,
                          width: width10 * 6,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: width10 / 2,
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: width10 * 9),
                      child: Text(
                        widget.song.title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    Text(
                      widget.song.artist,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: Navigator.of(context).pop,
            padding: EdgeInsets.all(5),
          ),
        ),
      ],
    );
  }
}
