import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:assets_audio_player/assets_audio_player.dart";

import "package:Music/routes/widgets/PlayPause.dart";
import "package:Music/constants.dart";
import "package:Music/models/models.dart";
import "package:Music/CustomIcons.dart";
import "package:Music/bloc/queue_bloc.dart";

class ControlBar extends StatelessWidget {
  final SongData song;
  final bool shuffled;
  final bool loop;
  final AssetsAudioPlayer audioPlayer;

  ControlBar({@required this.song, this.shuffled = false, this.loop = false})
      : audioPlayer = AssetsAudioPlayer.withId(playerId);

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.width / 10;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: width10 * 0.9),
      child: Material(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.playlist_add),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(CustomIcons.shuffle),
              color: shuffled ? Theme.of(context).accentColor : Colors.white,
              onPressed: () {
                BlocProvider.of<QueueBloc>(context).add(ShuffleSongs());
              },
            ),
            IconButton(
              icon: Icon(Icons.fast_rewind),
              disabledColor: Colors.grey[400],
              onPressed: () {
                BlocProvider.of<QueueBloc>(context).add(PrevSong());
              },
            ),
            PlayPause(audioPlayer),
            IconButton(
              icon: Icon(Icons.fast_forward),
              disabledColor: Colors.grey[400],
              onPressed: () {
                BlocProvider.of<QueueBloc>(context).add(NextSong());
              },
            ),
            IconButton(
              icon: Icon(CustomIcons.loop),
              color: loop ? Theme.of(context).accentColor : Colors.white,
              onPressed: () {
                BlocProvider.of<QueueBloc>(context).add(LoopSongs());
              },
            ),
            IconButton(
              icon: song.liked
                  ? Icon(Icons.favorite, color: Colors.red[900])
                  : Icon(Icons.favorite_border),
              onPressed: () {
                BlocProvider.of<QueueBloc>(context).add(ToggleLikedSong(song));
              },
            ),
          ],
        ),
      ),
    );
  }
}
