import 'package:flutter/material.dart';

import '../constants.dart';
import '../keys.dart';
import './widgets/Input.dart';
import './widgets/CurrentSongBanner.dart';
import './views/Albums.dart';
import './views/Artists.dart';
import './views/Home.dart';
import './views/Music.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPage = 0;
  final _pageController = PageController(initialPage: 0, keepPage: true);
  final _textController = TextEditingController();

  final pages = <Widget>[
    Home(),
    Music(),
    Albums(),
    Artists(),
  ];

  void goHome() {
    setState(() {
      _currentPage = 0;
      _pageController.animateToPage(0,
          duration: Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    });
  }

  Future<void> _checkForApiKeys() async {
    if (await apiKeys.needsApiKeys) {
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.of(context).pushNamed('/register-apikeys');
    }
  }

  @override
  void initState() {
    _checkForApiKeys();

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
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
        title: Hero(
          tag: 'navbar-title',
          child: GestureDetector(
            onTap: goHome,
            child: Row(
              children: <Widget>[
                Image(
                  image: AssetImage('$imgs/icon.png'),
                  fit: BoxFit.scaleDown,
                  height: 2.5 * rem,
                ),
                Text(
                  'Music',
                  style: Theme.of(context).textTheme.headline6,
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
                  placeholder: 'Download',
                  controller: _textController,
                  onChange: (query) {
                    if (query.length > 0) {
                      Navigator.of(context)
                          .pushNamed('/search', arguments: query)
                          .then((_) {
                        FocusScope.of(context).unfocus();
                        _textController.text = '';
                      });
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CurrentSongBanner(),
          BottomNavigationBar(
            currentIndex: _currentPage,
            onTap: (int index) {
              setState(() {
                _currentPage = index;
                _pageController.animateToPage(index,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic);
              });
            },
            backgroundColor: Theme.of(context).backgroundColor,
            selectedItemColor: Color.fromRGBO(71, 135, 231, 1),
            unselectedItemColor: Colors.grey[200],
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'My Music',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Albums',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Artists',
              ),
            ],
          ),
        ],
      ),
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
          controller: _pageController,
        ),
      ),
    );
  }
}
