import 'package:flutter/material.dart';

import './routing.dart';
import "./themedata.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music",
      theme: themeData,
      initialRoute: "/",
      onGenerateRoute: Router.generateRoute,
    );
  }
}
