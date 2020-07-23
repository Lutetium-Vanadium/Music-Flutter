import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:rxdart/rxdart.dart';

import 'package:Music/constants.dart';
import 'package:Music/models/song_data.dart';

class AudioPlayerProvider extends StatelessWidget {
  final Widget child;
  final AudioPlayer player;

  const AudioPlayerProvider({Key key, this.player, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      onKey: (e) {
        if (e.runtimeType == RawKeyUpEvent &&
            e.data is RawKeyEventDataAndroid &&
            (e.data as RawKeyEventDataAndroid).keyCode == 79) {
          player.togglePlay();
        }
      },
      focusNode: FocusNode(
          // canRequestFocus: false,
          ),
      child: child,
    );
  }

  static AudioPlayer getPlayer(BuildContext context) {
    assert(context != null);
    final AudioPlayerProvider result =
        context.findAncestorWidgetOfExactType<AudioPlayerProvider>();

    if (result != null) return result.player;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'AudioPlayerProvider.getPlayer() called with a context that does not contain a AudioPlayerProvider.'),
      ErrorDescription(
          'No AudioPlayerProvider ancestor could be found starting from the context that was passed to AudioPlayerProvider.getPlayer(). '
          'This usually happens when the context provided is from the same StatefulWidget as that '
          'whose build function actually creates the AudioPlayerProvider widget being sought.'),
      context.describeElement('The context used was')
    ]);
  }
}

typedef CurrentPositionBuilder = Widget Function(
    BuildContext context, int timestamp);
typedef PlayingBuilder = Widget Function(BuildContext context, bool isPlaying);

class AudioPlayerBuilder<T> extends StatelessWidget {
  final AudioPlayer player;
  final Widget Function(BuildContext, T) builder;
  final _AudioPlayerBuilder _type;

  AudioPlayerBuilder(
    this._type, {
    @required BuildContext context,
    @required this.builder,
    Key key,
  })  : player = AudioPlayerProvider.getPlayer(context),
        super(key: key);

  static isPlaying({
    @required PlayingBuilder builder,
    @required BuildContext context,
    Key key,
  }) {
    return AudioPlayerBuilder<bool>(
      _AudioPlayerBuilder.Playing,
      builder: builder,
      context: context,
      key: key,
    );
  }

  static currentPosition({
    @required CurrentPositionBuilder builder,
    @required BuildContext context,
    Key key,
  }) {
    return AudioPlayerBuilder<int>(
      _AudioPlayerBuilder.CurrentPosition,
      builder: builder,
      context: context,
      key: key,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case _AudioPlayerBuilder.Playing:
        return StreamBuilder<bool>(
          stream: player.isPlaying,
          initialData: false,
          builder: (context, snapshot) {
            return builder(context, snapshot.data as T);
          },
        );
      case _AudioPlayerBuilder.CurrentPosition:
        return StreamBuilder<Duration>(
          stream: player.currentPosition,
          initialData: Duration.zero,
          builder: (context, snapshot) {
            return builder(context, snapshot.data.inSeconds as T);
          },
        );
      default:
        throw 'Unknown Type: $_type';
    }
  }
}

enum _AudioPlayerBuilder {
  Playing,
  CurrentPosition,
}

class AudioPlayer {
  AssetsAudioPlayer player;
  VoidCallback _callback;

  bool _playing = false;

  void onNext(VoidCallback callback) {
    _callback = callback;
  }

  AudioPlayer() {
    player = AssetsAudioPlayer.newPlayer();

    player.playlistAudioFinished.listen((_) => _callback());
  }

  Future<void> playSong(
    SongData song,
    String albumName,
    NotificationSettings notificationSettings,
  ) {
    _playing = true;
    return player.open(
      Audio.file(
        song.filePath,
        metas: Metas(
          album: albumName,
          artist: song.artist,
          title: song.title,
          image: MetasImage.file(song.thumbnail),
          onImageLoadFail: MetasImage.asset('$imgs/music_symbol.png'),
        ),
      ),
      showNotification: true,
      notificationSettings: notificationSettings,
    );
  }

  Future<void> stop() {
    _playing = false;
    return player.stop();
  }

  Future<void> seek(int time) => player.seek(Duration(seconds: time));

  Future<void> togglePlay() async {
    if (_playing) await player.playOrPause();
  }

  ValueStream<bool> get isPlaying => player.isPlaying;
  ValueStream<Duration> get currentPosition => player.currentPosition;
}
