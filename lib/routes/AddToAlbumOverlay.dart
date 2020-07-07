import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:Music/global_providers/database.dart";
import "package:Music/models/models.dart";
import "package:Music/bloc/data_bloc.dart";
import "package:Music/constants.dart";
import "package:Music/CustomSplashFactory.dart";

class AddToAlbumOverlay extends StatefulWidget {
  final SongData song;

  const AddToAlbumOverlay(this.song, {Key key}) : super(key: key);

  @override
  _AddToAlbumOverlayState createState() => _AddToAlbumOverlayState();
}

class _AddToAlbumOverlayState extends State<AddToAlbumOverlay> {
  int _selected;
  List<CustomAlbumData> _albums = [];

  Future<void> getAlbums() async {
    var albums = await DatabaseProvider.getDB(context).getCustomAlbums();

    if (!mounted) return;

    setState(() {
      _albums = albums;
    });
  }

  @override
  void initState() {
    getAlbums();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DataBloc, DataState>(
      listener: (context, state) {
        if (state is UpdateData) {
          getAlbums();
        }
      },
      child: Column(
        children: <Widget>[
          _buildNav(context),
          Expanded(
            child: ListView.builder(
              itemCount: _albums.length + 1,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == _albums.length) {
                  return Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).colorScheme.primaryVariant,
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.add),
                        onPressed: () =>
                            Navigator.of(context).pushNamed("/select-songs"),
                      ),
                    ),
                  );
                }

                return Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 0.6 * rem,
                    horizontal: 1.2 * rem,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(rem / 2),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: _buildAlbumDetails(context, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNav(BuildContext context) {
    var width10 = MediaQuery.of(context).size.width / 10;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: 0.25 * width10, right: 0.4 * width10),
            child: Material(
              borderRadius: BorderRadius.circular(40),
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ),
          Expanded(
            child: Text(
              widget.song.title,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: 7,
              right: 20,
              left: 0.8 * width10,
            ),
            child: FlatButton(
              onPressed: _selected == null
                  ? null
                  : () {
                      BlocProvider.of<DataBloc>(context)
                          .add(AddSongToCustomAlbum(
                        id: _albums[_selected].id,
                        song: widget.song,
                      ));

                      Navigator.of(context).pop();
                    },
              child: Text("Add"),
              color: Theme.of(context).accentColor,
              disabledColor: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              visualDensity: VisualDensity.comfortable,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumDetails(BuildContext context, int index) {
    var album = _albums[index];

    return InkWell(
      onTap: () {
        setState(() {
          _selected = index;
        });
      },
      splashFactory: CustomSplashFactory(),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(rem / 2),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0.6 * rem,
          horizontal: 1.2 * rem,
        ),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0.6 * rem),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0.4 * rem),
                child: Image.asset(
                  "$imgs/music_symbol.png",
                  width: 4 * rem,
                  height: 4 * rem,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: rem, right: 1.5 * rem),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      album.name,
                      style: Theme.of(context).textTheme.bodyText1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${album.songs.length} ${album.songs.length == 1 ? "song" : "songs"}",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 13, right: 3),
              child: _selected == index
                  ? Icon(
                      Icons.check_box,
                      size: 25,
                      color: Theme.of(context).accentColor,
                    )
                  : Icon(Icons.check_box_outline_blank, size: 25),
            ),
          ],
        ),
      ),
    );
  }
}
