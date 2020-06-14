import 'package:flutter/material.dart';

import "./themedata.dart";
import "./layout.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music",
      theme: themeData,
      home: Layout(),
    );
  }
}
