import 'package:Music/helpers/formatLength.dart';
import "package:flutter/material.dart";

import 'package:Music/constants.dart';
import "package:Music/dataClasses.dart";

class SongView extends StatelessWidget {
  final List<NapsterSongData> songs;
  final void Function(NapsterSongData, int) onClick;
  final IconData iconData;

  SongView({@required this.songs, this.onClick, this.iconData});

  @override
  Widget build(BuildContext context) {
    if (songs == null || songs.length == 0) {
      return Center(
        child: Container(
          width: 50,
          height: 50,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).buttonColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 5,
          ),
        ),
        // child: Text(
        //   "Home",
        //   style: Theme.of(context).textTheme.headline1,
        // ),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: rem / 2, bottom: 2 * rem),
      itemCount: songs.length,
      itemBuilder: (ctx, index) {
        var song = songs[index];

        return GestureDetector(
          onTap: () {
            onClick(song, index);
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: 0.6 * rem,
              horizontal: 1.2 * rem,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 0.6 * rem,
              horizontal: 1.2 * rem,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rem / 2),
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0.6 * rem),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.4 * rem),
                    child: Image.network(
                      song.thumbnail,
                      fit: BoxFit.scaleDown,
                      width: 4 * rem,
                      height: 4 * rem,
                      frameBuilder: (ctx, widget, frame, synchronouslyLoaded) {
                        if (synchronouslyLoaded) {
                          return widget;
                        }

                        return AnimatedCrossFade(
                          firstChild: Image.asset(
                            "$imgs/music_symbol.png",
                            fit: BoxFit.scaleDown,
                            width: 4 * rem,
                            height: 4 * rem,
                          ),
                          secondChild: widget,
                          crossFadeState: frame == null
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: Duration(milliseconds: 400),
                        );
                      },
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
                          song.title,
                          style: Theme.of(context).textTheme.bodyText1,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0.5 * rem, left: 0.8 * rem),
                          child: Text(
                            song.artist,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(formatLength(song.length)),
                Padding(
                  padding: iconData == null
                      ? EdgeInsets.all(0)
                      : EdgeInsets.only(left: 13, right: 3),
                  child: Icon(
                    iconData,
                    size: 1.5 * rem,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
