import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'package:Music/bloc/data_bloc.dart';
import 'package:Music/bloc/queue_bloc.dart';
import 'package:Music/models/models.dart';
import 'package:Music/CustomSplashFactory.dart';
import 'package:Music/constants.dart';
import 'package:Music/helpers/formatLength.dart';

import './showConfirm.dart';

class SongView extends StatelessWidget {
  final SongMetadata song;
  final VoidCallback onClick;
  final Widget icon;
  final Image image;
  final bool showFocusedMenuItems;

  const SongView({
    @required this.song,
    @required this.image,
    this.onClick,
    this.icon,
    this.showFocusedMenuItems = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(context) {
    bool liked;
    if (song is SongData) {
      liked = (song as SongData).liked;
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
        child: (!showFocusedMenuItems || liked == null)
            ? _buildSongDetails(context)
            : FocusedMenuHolder(
                menuItems: [
                  FocusedMenuItem(
                    onPressed: onClick,
                    title: Text('Play'),
                    trailingIcon: Icon(Icons.play_arrow),
                    backgroundColor: Colors.transparent,
                  ),
                  FocusedMenuItem(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/add-to-album', arguments: song),
                    title: Text('Add to Album'),
                    trailingIcon: Icon(Icons.playlist_add),
                    backgroundColor: Colors.transparent,
                  ),
                  FocusedMenuItem(
                    onPressed: () {
                      BlocProvider.of<QueueBloc>(context)
                          .add(ToggleLikedSong(song));
                    },
                    title: liked ? Text('Unlike') : Text('Like'),
                    trailingIcon: liked
                        ? Icon(Icons.favorite)
                        : Icon(Icons.favorite_border),
                    backgroundColor: Colors.transparent,
                  ),
                  FocusedMenuItem(
                    onPressed: () async {
                      if (await showConfirm(
                        context,
                        'Delete ${song.title}',
                        'Are you sure you want to delete ${song.title} by ${song.artist}?',
                      )) {
                        BlocProvider.of<QueueBloc>(context)
                            .add(DeleteSong(song));
                      }
                    },
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    trailingIcon: Icon(Icons.delete, color: Colors.red),
                    backgroundColor: Colors.transparent,
                  ),
                ],
                child: _buildSongDetails(context),
                onPressed: () {},
                animateMenuItems: false,
                blurSize: 5,
                menuBoxDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Theme.of(context).canvasColor.withOpacity(0.69),
                ),
                blurBackgroundColor: Colors.transparent,
                duration: Duration(milliseconds: 300),
                menuWidth: 150,
              ),
      ),
    );
  }

  Widget _buildSongDetails(BuildContext context) {
    return InkWell(
      onTap: onClick,
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
                child: image,
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
                      song.title,
                      style: Theme.of(context).textTheme.bodyText1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.artist,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
              ),
            ),
            Text(formatLength(song.length)),
            Padding(
              padding: EdgeInsets.only(left: 13, right: 3),
              child: icon,
            ),
          ],
        ),
      ),
    );
  }
}
