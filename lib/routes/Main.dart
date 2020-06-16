import 'package:flutter/material.dart';

import "../constants.dart";
import "../input.dart";

import "./views/Albums.dart";
import "./views/Artists.dart";
import "./views/Home.dart";
import "./views/Music.dart";

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentPage = 0;

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
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).backgroundColor,
        textTheme: Theme.of(context).textTheme,
        title: Hero(
          tag: "navbar-title",
          child: GestureDetector(
            onTap: goHome,
            child: Row(
              children: <Widget>[
                Image(
                  image: AssetImage("$imgs/icon.png"),
                  fit: BoxFit.scaleDown,
                  height: 2.5 * rem,
                ),
                Text(
                  "Music",
                  style: TextStyle(color: Colors.white, fontSize: 1.5 * rem),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            width: MediaQuery.of(context).size.width / 2 - 30,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
            child: Hero(
              tag: "navbar-search",
              child: Row(
                children: <Widget>[
                  Input(
                    placeholder: "Download",
                    onChange: (query) {
                      if (query.length > 0) {
                        Navigator.of(context)
                            .pushNamed("/search", arguments: query);
                      }
                    },
                  ),
                  Icon(Icons.search),
                ],
              ),
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
