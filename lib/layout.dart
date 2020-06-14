import 'package:flutter/material.dart';
import "./constants.dart";
import "./input.dart";

import "./views/Albums.dart";
import "./views/Artists.dart";
import "./views/Home.dart";
import "./views/Music.dart";

class Layout extends StatefulWidget {
  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _currentPage = 4;

  final pages = <Widget>[
    Home(),
    Music(),
    Artists(),
    Albums(),
  ];

  void goHome() {
    setState(() {
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        textTheme: Theme.of(context).textTheme,
        leading: GestureDetector(
          onTap: goHome,
          child: Container(
            margin: EdgeInsets.only(left: 10.0),
            padding: EdgeInsets.all(4.0),
            child: Image(
              image: AssetImage("graphics/icon.png"),
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
        title: GestureDetector(
          onTap: goHome,
          child: Container(
            child: Text(
              "Music",
              style: TextStyle(color: Colors.white, fontSize: 1.5 * rem),
            ),
            transform: Matrix4.translationValues(-20, 0, 0),
          ),
        ),
        actions: [
          Container(
            width: MediaQuery.of(context).size.width / 2 - 30,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
            child: Row(
              children: <Widget>[
                Input(
                  placeholder: "Download",
                  onChange: print,
                ),
                Icon(Icons.search),
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
        primary: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
        backgroundColor: Theme.of(context).backgroundColor,
        selectedItemColor: Theme.of(context).accentTextTheme.bodyText1.color,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            title: Text("My Music"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text("Artists"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            title: Text("Albums"),
          ),
        ],
      ),
      body: IndexedStack(
        children: pages,
        index: _currentPage,
      ),
    );
  }
}
