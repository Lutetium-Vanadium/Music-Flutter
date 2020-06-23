import "dart:io";

import "package:flutter/material.dart";

class Mozaic extends StatelessWidget {
  final List<String> images;
  final double totalWidth;

  const Mozaic(this.images, this.totalWidth, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.file(
              File(images[0]),
              width: totalWidth / 2,
              height: totalWidth / 2,
            ),
            Image.file(
              File(images[1]),
              width: totalWidth / 2,
              height: totalWidth / 2,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Image.file(
              File(images[2]),
              width: totalWidth / 2,
              height: totalWidth / 2,
            ),
            Image.file(
              File(images[3]),
              width: totalWidth / 2,
              height: totalWidth / 2,
            ),
          ],
        ),
      ],
    );
  }
}
