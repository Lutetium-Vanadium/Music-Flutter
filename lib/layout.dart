import 'package:flutter/material.dart';
import "./constants.dart";
import "./input.dart";

class Layout extends StatelessWidget {
  final Widget child;

  Layout({this.child});
  static const routes = ["/music", "/artists", "/albums", "/settings"];

  @override
  Widget build(BuildContext context) {
    int page = routes.indexOf(ModalRoute.of(context).settings.name);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        textTheme: Theme.of(context).textTheme,
        leading: Container(
          margin: EdgeInsets.only(left: 10.0),
          padding: EdgeInsets.all(4.0),
          child: Image(
            image: AssetImage("graphics/icon.png"),
            fit: BoxFit.scaleDown,
          ),
        ),
        title: Container(
          child: Text(
            "Music",
            style: TextStyle(color: Colors.white, fontSize: 1.5 * rem),
          ),
          transform: Matrix4.translationValues(-20, 0, 0),
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
        currentIndex: page == -1 ? null : page,
        onTap: (int index) {
          Navigator.pushNamed(context, routes[index]);
        },
        selectedItemColor: Theme.of(context).accentTextTheme.bodyText1.color,
        backgroundColor: Theme.of(context).backgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            title: Text("Songs"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text("Artists"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            title: Text("Albums"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("Settings"),
          ),
        ],
      ),
      body: child,
    );
  }
}
