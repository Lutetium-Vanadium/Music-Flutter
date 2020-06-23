import 'dart:io';
import 'package:flutter/material.dart';

import 'package:Music/constants.dart';

import 'Mozaic.dart';

class CoverImage extends StatelessWidget {
  final String image;
  final List<String> images;
  final String title;
  final String subtitle;
  final bool isBig;
  final Object tag;
  final VoidCallback onClick;

  CoverImage({
    @required this.title,
    this.image,
    this.images,
    this.subtitle = "",
    this.isBig = false,
    this.onClick,
    this.tag,
  }) {
    assert(image != null || images != null);
    if (images != null) {
      assert(images.length == 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var width10 = size.shortestSide / 10;
    var imgWidth = width10 * (isBig ? 4.1 : 3.8);

    var img = images != null
        ? Mozaic(images, imgWidth)
        : Image.file(
            File(image),
            height: imgWidth,
            width: imgWidth,
          );

    return Container(
      width: imgWidth,
      height: imgWidth + 3 * rem,
      margin: EdgeInsets.all(isBig ? width10 * 0.3 : width10 / 4),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: onClick,
            child: ClipRRect(
              child: tag == null
                  ? img
                  : Hero(
                      tag: tag,
                      child: img,
                    ),
              borderRadius: BorderRadius.circular(10),
            ),
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
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
    );
  }
}
