import "dart:ui";
import "package:flutter/material.dart";

class OverlayPageRoute<T> extends PageRoute<T> {
  final Widget child;

  OverlayPageRoute({this.child}) : super(fullscreenDialog: true);

  static const radius = Radius.circular(30);

  @override
  final barrierColor = null;

  @override
  final barrierLabel = null;

  @override
  final opaque = false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    var size = MediaQuery.of(context).size;
    var tween = Tween(begin: Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(curve: Curves.easeOutCubic, parent: animation));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: Navigator.of(context).pop,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4,
            sigmaY: 4,
          ),
          child: Container(
            width: size.width,
            height: size.height,
            color: Theme.of(context).backgroundColor.withOpacity(0.2),
            child: GestureDetector(
              onTap: () {},
              child: SlideTransition(
                position: tween,
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  widthFactor: 1,
                  heightFactor: 0.55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: radius),
                    child: Container(
                      color: Theme.of(context).colorScheme.secondary,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
}
