import "package:flutter/material.dart";

import "./routes/Main.dart";
import "./routes/Search.dart";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (_) => Main(),
        );
        break;
      case "/search":
        return MaterialPageRoute(
          builder: (_) => Search(settings.arguments),
        );
        break;
      default:
        return MaterialPageRoute(
          builder: (_) => Text("Error, couldn't find route: " + settings.name),
        );
    }
  }
}
