import 'dart:io';
import 'package:flutter/material.dart';

import 'package:Music/constants.dart';

class CoverImage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  CoverImage({this.image, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var width10 = size.shortestSide / 10;
    var imgWidth = width10 * 3.8;

    return Container(
      width: imgWidth,
      height: imgWidth + 3 * rem,
      margin: EdgeInsets.all(width10 / 4),
      child: Column(
        children: <Widget>[
          ClipRRect(
            child: Image.file(File(image)),
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: rem / 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
    );
  }
}
