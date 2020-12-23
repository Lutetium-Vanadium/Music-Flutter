import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Music/global_providers/database.dart';
import 'package:Music/bloc/data_bloc.dart';
import 'package:Music/models/models.dart';
import 'package:Music/routes/widgets/SongList.dart';

class SelectSongsOverlay extends StatefulWidget {
  final CustomAlbumData album;

  const SelectSongsOverlay({Key key, this.album}) : super(key: key);

  @override
  _SelectSongsOverlayState createState() => _SelectSongsOverlayState();
}

class _SelectSongsOverlayState extends State<SelectSongsOverlay> {
  var _controller = TextEditingController();
  bool create;
  List<SelectedSongData> _songs;
  int _numSelected = 0;

  @override
  void initState() {
    create = widget.album == null;
    _getAllSongs();
    super.initState();
  }

  Future<void> _getAllSongs() async {
    var selected = Set<String>();

    if (!create) {
      selected = widget.album.songs.toSet();
    }

    var songs = await DatabaseProvider.getDB(context).getSongs();

    var selectedSongs = List.generate(songs.length, (index) {
      var song = songs[index];

      return SelectedSongData(song, selected: selected.contains(song.title));
    });

    if (mounted) {
      setState(() {
        _songs = selectedSongs;
        _numSelected = selected.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildNav(context),
        Expanded(
          child: SongList(
            songs: _songs,
            showFocusedMenuItems: false,
            onClick: (song, index) => setState(() {
              _songs[index] = _songs[index].toggleSelected();
              if (_songs[index].selected) {
                _numSelected++;
              } else {
                _numSelected--;
              }
            }),
            getIcon: (index) => _songs[index].selected
                ? Icon(
                    Icons.check_box,
                    size: 25,
                    color: Theme.of(context).accentColor,
                  )
                : Icon(Icons.check_box_outline_blank, size: 25),
          ),
        )
      ],
    );
  }

  Widget _buildNav(context) {
    var width10 = MediaQuery.of(context).size.width / 10;

    var cantSubmit =
        (create && _controller.text.length == 0) || _numSelected == 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: 0.25 * width10, right: 0.4 * width10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Material(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: Navigator.of(context).pop,
                ),
              ),
            ),
          ),
          Expanded(
            child: create
                ? TextField(
                    controller: _controller,
                    style: Theme.of(context).textTheme.bodyText1,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Album Name',
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    textAlign: TextAlign.center,
                    onChanged: (_) {
                      if (cantSubmit && _numSelected > 0) {
                        // cantSubmit was true because the name was empty. Refresh the widget to
                        // show that you can submit
                        setState(() {});
                      }
                    },
                  )
                : Text(
                    widget.album.name,
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
              onPressed: cantSubmit
                  ? null
                  : () {
                      if (create) {
                        BlocProvider.of<DataBloc>(context).add(AddCustomAlbum(
                          name: _controller.text,
                          songs: _songs
                              .where((s) => s.selected)
                              .map((s) => s.title)
                              .toList(),
                        ));
                      } else {
                        BlocProvider.of<DataBloc>(context).add(EditCustomAlbum(
                          id: widget.album.id,
                          songs: _songs
                              .where((s) => s.selected)
                              .map((s) => s.title)
                              .toList(),
                        ));
                      }

                      Navigator.of(context).pop();
                    },
              child: Text(create ? 'Create' : 'Edit'),
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
}
