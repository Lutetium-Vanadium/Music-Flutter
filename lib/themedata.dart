import 'package:flutter/material.dart';
import "./constants.dart";

TextTheme createTextTheme(Color col) {
  return TextTheme(
    bodyText1: TextStyle(color: col, fontSize: 1.2 * rem),
    bodyText2: TextStyle(color: col),
    button: TextStyle(color: col),
    caption: TextStyle(color: col),
    headline1: TextStyle(
      color: col,
      fontSize: 4 * rem,
      fontWeight: FontWeight.w700,
    ),
    headline2: TextStyle(
      color: col,
      fontSize: 3.4 * rem,
      fontWeight: FontWeight.w700,
    ),
    headline3: TextStyle(
      color: col,
      fontSize: 3 * rem,
      fontWeight: FontWeight.w600,
    ),
    headline4: TextStyle(
      color: col,
      fontSize: 2.5 * rem,
      fontWeight: FontWeight.w600,
    ),
    headline5: TextStyle(
      color: col,
      fontSize: 2 * rem,
      fontWeight: FontWeight.w500,
    ),
    headline6: TextStyle(
      color: col,
      fontSize: 1.4 * rem,
      fontWeight: FontWeight.w500,
    ),
  );
}

var textTheme = createTextTheme(Colors.white);

var themeData = ThemeData(
  primaryColor: Color.fromRGBO(50, 50, 50, 1),
  accentColor: Color.fromRGBO(23, 99, 212, 1),
  backgroundColor: Color.fromRGBO(20, 20, 20, 1),
  textTheme: textTheme,
  appBarTheme: AppBarTheme(
    elevation: 0,
  ),
  primaryTextTheme: textTheme,
  bottomAppBarTheme: BottomAppBarTheme(
    elevation: 0,
  ),
  buttonColor: Color.fromRGBO(23, 99, 212, 1),
  bottomAppBarColor: Color.fromRGBO(27, 27, 27, 1),
  cursorColor: Colors.grey[100],
  hintColor: Colors.grey[400],
  canvasColor: Color.fromRGBO(27, 27, 27, 1),
  accentTextTheme: createTextTheme(Color.fromRGBO(71, 135, 231, 1)),
);
