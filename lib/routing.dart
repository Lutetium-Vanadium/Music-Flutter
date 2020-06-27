import "package:flutter/cupertino.dart";

import "models/models.dart";
import "./routes/MainPage.dart";
import "./routes/SearchPage.dart";
import "./routes/ArtistPage.dart";
import "./routes/AlbumPage.dart";
import "./routes/CurrentSongPage.dart";

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
        assert(settings.arguments is AlbumData);
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => AlbumPage(settings.arguments),
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
      default:
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => Text("Error, couldn't find route: " + settings.name),
        );
    }
  }
}
