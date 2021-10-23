import 'package:flutter/material.dart';
import './constants.dart';

TextTheme createTextTheme(Color col) {
  return TextTheme(
    bodyText1: TextStyle(color: col, fontSize: 1.2 * rem),
    bodyText2: TextStyle(color: col),
    button: TextStyle(color: col),
    caption: TextStyle(color: col),
    headline1: TextStyle(
      color: col,
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      shadows: [
        Shadow(color: Colors.black38, blurRadius: 10, offset: Offset(3, 3))
      ],
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
    subtitle1: TextStyle(
      fontSize: 18,
      color: Colors.grey[400],
    ),
    subtitle2: TextStyle(
      fontSize: 13,
      color: Colors.grey[400],
    ),
  );
}

var textTheme = createTextTheme(Colors.white);

Color getTextButtonColor(Set<MaterialState> states) {
  if (states.contains(MaterialState.disabled)) {
    return Colors.grey[850];
  } else {
    return Color.fromRGBO(18, 91, 193, 1);
  }
}

var themeData = ThemeData(
  primaryColor: Color.fromRGBO(50, 50, 50, 1),
  backgroundColor: Color.fromRGBO(20, 20, 20, 1),
  textTheme: textTheme,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.grey[100],
    selectionColor: Colors.grey[400],
    selectionHandleColor: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
  ),
  primaryTextTheme: textTheme,
  bottomAppBarTheme: BottomAppBarTheme(
    elevation: 0,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.white),
      backgroundColor: MaterialStateProperty.resolveWith(getTextButtonColor),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color.fromRGBO(18, 91, 193, 1),
    disabledColor: Colors.grey[850],
  ),
  bottomAppBarColor: Color.fromRGBO(27, 27, 27, 1),
  hintColor: Colors.grey[400],
  canvasColor: Color.fromRGBO(27, 27, 27, 1),
  // accentTextTheme: createTextTheme(Color.fromRGBO(71, 135, 231, 1)),
  colorScheme: ColorScheme(
    background: Color.fromRGBO(20, 20, 20, 1),
    brightness: Brightness.dark,
    error: Color(0xFFBE0003),
    onBackground: Colors.white,
    onError: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    primary: Color.fromRGBO(50, 50, 50, 1),
    primaryVariant: Color.fromRGBO(45, 45, 45, 1),
    secondary: Color.fromRGBO(29, 29, 29, 1),
    secondaryVariant: Color.fromRGBO(23, 99, 212, 1),
    surface: Color.fromRGBO(40, 40, 40, 1),
  ),
  brightness: Brightness.dark,
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color.fromRGBO(50, 50, 50, 1),
    contentTextStyle: textTheme.bodyText2,
  ),
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    },
  ),
);
