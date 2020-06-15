import 'package:Music/helpers/formatLength.dart';
import "package:flutter/material.dart";

import 'package:Music/constants.dart';
import "package:Music/dataClasses.dart";

class SongView extends StatelessWidget {
  final List<NapsterSongData> songs;
  final void Function(NapsterSongData, int) onClick;

  SongView({this.songs, this.onClick});

  @override
  Widget build(BuildContext context) {
    if (songs.length > 0) {
      print("TITLE2: ${songs.first.title}");
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 1.5 * rem),
      itemCount: songs.length,
      itemBuilder: (ctx, index) {
        var song = songs[index];

        return GestureDetector(
          onTap: () {
            onClick(song, index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: 0.6 * rem, horizontal: 1.2 * rem),
            height: 8 * rem,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 0.6 * rem),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.4 * rem),
                    child: Image.network(
                      song.thumbnail,
                      fit: BoxFit.scaleDown,
                      width: 4 * rem,
                      height: 4 * rem,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: rem),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(song.title,
                            style: Theme.of(context).textTheme.bodyText1),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.8 * rem),
                          child: Text(song.artist,
                              style: Theme.of(context).textTheme.bodyText2),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(formatLength(song.length)),
              ],
            ),
          ),
        );
      },
    );
  }
}
