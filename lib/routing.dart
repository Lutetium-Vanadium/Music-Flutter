import "dart:ui";
import "package:flutter/cupertino.dart";

import "./models/models.dart";
import "./OverlayPageRoute.dart";
import "./routes/MainPage.dart";
import "./routes/SearchPage.dart";
import "./routes/ArtistPage.dart";
import "./routes/AlbumPage.dart";
import "./routes/CustomAlbumPage.dart";
import "./routes/LikedPage.dart";
import "./routes/CurrentSongPage.dart";
import "./routes/SelectSongsOverlay.dart";
import "./routes/AddToAlbumOverlay.dart";
import "./routes/RegisterApiKeys.dart";

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
      case "/register-apikeys":
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => RegisterApiKeys(),
        );
      case "/select-songs":
        assert(settings.arguments == null ||
            settings.arguments is CustomAlbumData);
        return OverlayPageRoute(
          child: SelectSongsOverlay(album: settings.arguments),
        );
      case "/add-to-album":
        assert(settings.arguments is SongData);
        return OverlayPageRoute(
          child: AddToAlbumOverlay(settings.arguments),
        );

      default:
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => Text("Error, couldn't find route: " + settings.name),
        );
    }
  }
}
