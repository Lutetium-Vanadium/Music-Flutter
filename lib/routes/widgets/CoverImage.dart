import 'dart:io';
import 'package:flutter/material.dart';

import 'package:Music/constants.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'Mozaic.dart';

class CoverImage extends StatelessWidget {
  final String image;
  final List<String> images;
  final String title;
  final String subtitle;
  final bool isBig;
  final Object tag;
  final VoidCallback onClick;
  final List<FocusedMenuItem> focusedMenuItems;
  final bool isAssetImage;

  CoverImage({
    @required this.title,
    this.image,
    this.images,
    this.subtitle = '',
    this.isBig = false,
    this.tag,
    this.onClick,
    this.focusedMenuItems,
    this.isAssetImage = false,
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
    var menuWidth = width10 * (isBig ? 4.7 : 4.2);

    var img = images != null
        ? Mozaic(images, imgWidth)
        : isAssetImage
            ? Image.asset(
                '$imgs/$image',
                height: imgWidth,
                width: imgWidth,
              )
            : Image.file(
                File(image),
                height: imgWidth,
                width: imgWidth,
              );

    var widget = Container(
      width: imgWidth,
      height: imgWidth + 3 * rem,
      margin: EdgeInsets.all(isBig ? width10 * 0.3 : width10 / 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            child: tag == null
                ? img
                : Hero(
                    tag: tag,
                    child: img,
                  ),
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: rem / 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
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

    if (focusedMenuItems == null) {
      return GestureDetector(
        onTap: onClick,
        child: widget,
      );
    } else {
      return FocusedMenuHolder(
        menuItems: focusedMenuItems,
        child: widget,
        onPressed: onClick,
        animateMenuItems: false,
        blurSize: 5,
        menuBoxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Theme.of(context).canvasColor.withOpacity(0.69),
        ),
        blurBackgroundColor: Colors.transparent,
        duration: Duration(milliseconds: 300),
        menuWidth: menuWidth,
      );
    }
  }
}
