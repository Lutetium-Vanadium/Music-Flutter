import "dart:io";
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
          onVerticalDragCancel: () => print("Cancel"),
          onVerticalDragEnd: (dragEndDetails) {
            var delta = _dragUpdateDetails.localPosition.dy -
                _dragStartDetails.localPosition.dy;
            print(dragEndDetails.velocity);
            if (delta > threshold ||
                dragEndDetails.velocity.pixelsPerSecond.dy > threshold) {
              Navigator.of(context).pop();
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            width: 10 * width10,
            height: 10 * width10,
            padding: EdgeInsets.only(
              left: width10,
              right: width10,
              top: 2 * width10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.colour.withOpacity(0.9),
                  widget.colour.withOpacity(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
