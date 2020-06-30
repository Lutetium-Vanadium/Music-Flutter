import "package:flutter/material.dart";

import "../constants.dart";
import "./widgets/Input.dart";
import "./widgets/CurrentSongBanner.dart";
import "./views/Albums.dart";
import "./views/Artists.dart";
import "./views/Home.dart";
import "./views/Music.dart";

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPage = 0;
  final _controller = PageController(initialPage: 0, keepPage: true);

  final pages = <Widget>[
    Home(),
    Music(),
    Albums(),
    Artists(),
  ];

  void goHome() {
    setState(() {
      _currentPage = 0;
      _controller.animateToPage(0,
          duration: Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
            _controller.animateToPage(index,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOutCubic);
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
            icon: Icon(Icons.library_music),
            title: Text("Albums"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text("Artists"),
          ),
        ],
      ),
      persistentFooterButtons: <Widget>[
        CurrentSongBanner(),
      ],
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: PageView.builder(
          itemBuilder: (context, index) {
            return pages[index];
          },
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          physics: BouncingScrollPhysics(),
          itemCount: pages.length,
          controller: _controller,
        ),
      ),
    );
  }
}
