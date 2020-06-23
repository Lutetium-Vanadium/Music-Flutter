import "package:flutter/cupertino.dart";

import "models/models.dart";
import "./routes/MainPage.dart";
import "./routes/SearchPage.dart";
import "./routes/ArtistPage.dart";
import "./routes/AlbumsPage.dart";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return CupertinoPageRoute(
          maintainState: false,
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
      default:
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => Text("Error, couldn't find route: " + settings.name),
        );
    }
  }
}
