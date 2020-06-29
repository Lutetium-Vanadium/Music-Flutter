import "dart:ui";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "models/models.dart";
import "./routes/MainPage.dart";
import "./routes/SearchPage.dart";
import "./routes/ArtistPage.dart";
import "./routes/AlbumPage.dart";
import "./routes/CustomAlbumPage.dart";
import "./routes/LikedPage.dart";
import "./routes/CurrentSongPage.dart";
import "./routes/SelectSongsOverlay.dart";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return CupertinoPageRoute(
          builder: (_) => MainPage(),
        );
        break;
      case "/search":
        assert(settings.arguments is String);
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => SearchPage(settings.arguments),
        );
        break;
      case "/artist":
        assert(settings.arguments is ArtistData);
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => ArtistPage(settings.arguments),
        );
      case "/album":
        assert(settings.arguments is AlbumData ||
            settings.arguments is CustomAlbumData);
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => (settings.arguments is AlbumData)
              ? AlbumPage(settings.arguments)
              : CustomAlbumPage(settings.arguments),
        );
      case "/liked":
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => LikedPage(),
        );
      case "/player":
        return PageRouteBuilder(
          maintainState: false,
          transitionDuration: Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondAnimation, child) {
            var offsetTween =
                Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic));
            var opacityTween = Tween<double>(begin: 0, end: 1)
                .chain(CurveTween(curve: Interval(0, 0.1)));

            return SlideTransition(
              position: offsetTween.animate(animation),
              child: FadeTransition(
                opacity: opacityTween.animate(animation),
                child: child,
              ),
            );
          },
          pageBuilder: (context, animation, secondAnimation) =>
              CurrentSongPage(),
        );
      case "/select-songs":
        assert(settings.arguments == null ||
            settings.arguments is CustomAlbumData);
        return PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 400),
          fullscreenDialog: true,
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) {
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
                        child: SelectSongsOverlay(album: settings.arguments),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );

      default:
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => Text("Error, couldn't find route: " + settings.name),
        );
    }
  }
}
