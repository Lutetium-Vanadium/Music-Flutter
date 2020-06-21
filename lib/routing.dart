import "package:flutter/cupertino.dart";

import "models/models.dart";
import "./routes/Main.dart";
import "./routes/Search.dart";
import "./routes/ArtistPage.dart";
import "./routes/AlbumsPage.dart";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return CupertinoPageRoute(
          builder: (_) => Main(),
        );
        break;
      case "/search":
        assert(settings.arguments is String);
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => Search(settings.arguments),
        );
        break;
      case "/artist":
        assert(settings.arguments is Artist);
        return CupertinoPageRoute(
          maintainState: false,
          builder: (_) => ArtistPage(settings.arguments),
        );
      case "/album":
        assert(settings.arguments is Album);
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
