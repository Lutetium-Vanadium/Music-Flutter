import 'package:flutter/material.dart';

import "./themedata.dart";
import "./layout.dart";

import "./views/Albums.dart";
import "./views/Artists.dart";
import "./views/Home.dart";
import "./views/Music.dart";
import "./views/Settings.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeData,
      initialRoute: "/",
      routes: {
        "/": (BuildContext context) => Layout(child: Home()),
        "/music": (BuildContext context) => Layout(child: Music()),
        "/artists": (BuildContext context) => Layout(child: Artists()),
        "/albums": (BuildContext context) => Layout(child: Albums()),
        "/settings": (BuildContext context) => Layout(child: Settings()),
      },
    );
  }
}
