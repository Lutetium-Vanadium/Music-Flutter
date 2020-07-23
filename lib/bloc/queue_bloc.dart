import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:Music/sync.dart';
import 'package:Music/global_providers/audio_player.dart';
import 'package:Music/global_providers/database.dart';
import 'package:Music/models/models.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final AudioPlayer audioPlayer;
  final DatabaseFunctions db;
  final FirestoreSync syncDb;

  QueueBloc(
      {DatabaseFunctions database,
      this.audioPlayer,
      FirestoreSync syncDatabase})
      : db = database,
        syncDb = syncDatabase,
        super(EmptyQueue()) {
    audioPlayer.onNext(() {
      this.add(NextSong());
    });
  }

  // Data
  List<SongData> _allSongs = []; // All songs in unshuffled order
  List<SongData> _songs = []; // Current queue
  int _index = 0;

  // Flags
  bool _isShuffled = false;
  bool _loop = false;

  List<SongData> _shuffle(List<SongData> songs, {int cur = -1}) {
    var currentIndex = songs.length - 1;
    int randomIndex;

    var random = Random();

    if (cur >= 0) {
      var temp = songs[0];
      songs[0] = songs[cur];
      songs[cur] = temp;
    }
    // While there remain elements to shuffle...
    while (currentIndex > 0) {
      // Pick a remaining element...
      randomIndex = random.nextInt(currentIndex) + 1;

      var temp = songs[currentIndex];
      songs[currentIndex] = songs[randomIndex];
      songs[randomIndex] = temp;

      currentIndex--;
    }

    return songs;
  }

  Future<void> _playSong(SongData song) async {
    var albumName = (await db.getAlbums(
      where: 'id LIKE ?',
      whereArgs: [song.albumId],
    ))
        .first
        .name;

    audioPlayer.playSong(
      song,
      albumName,
      NotificationSettings(
        customNextAction: (_) => this.add(NextSong()),
        customPrevAction: (_) => this.add(PrevSong()),
        customStopAction: (_) => this.add(DequeueSongs()),
      ),
    );

    await db.incrementNumListens(song);
    syncDb.incrementNumListens(song);
  }

  SongData get _current => _songs.length > 0 ? _songs[_index] : null;

  @override
  Stream<QueueState> mapEventToState(QueueEvent event) async* {
    var updateData = false;

    if (event is EnqueueSongs) {
      _allSongs = event.songs;
      _index = event.index;
      _isShuffled = event.shuffle;
      if (event.shuffle) {
        _songs = _shuffle([...event.songs], cur: event.index);
      } else {
        _songs = event.songs;
      }

      await _playSong(_current);
    } else if (event is ToggleLikedSong) {
      var liked = !event.song.liked;

      var allSongsIndex = _allSongs.indexOf(event.song);
      if (allSongsIndex >= 0) {
        _allSongs[allSongsIndex] = SongData.override(event.song, liked: liked);
      }

      var songsIndex = _songs.indexOf(event.song);
      if (songsIndex >= 0) {
        _songs[songsIndex] = SongData.override(event.song, liked: liked);
      }

      await db.update(
        Tables.Songs,
        {'liked': liked},
        where: 'title LIKE ?',
        whereArgs: [event.song.title],
      );
      syncDb.update(SyncTables.Songs, event.song.title, {'liked': liked});

      updateData = true;
    }

    if (_songs.length > 0) {
      if (event is DequeueSongs) {
        _songs = [];
        _allSongs = [];
        _index = 0;
        audioPlayer.stop();
      } else if (event is JumpToSong) {
        _index = event.index;
        await _playSong(_current);
      } else if (event is NextSong) {
        if (!_loop) {
          _index = (_index + 1) % _songs.length;
        }
        await _playSong(_current);
      } else if (event is PrevSong) {
        if (!_loop) {
          _index = (_index + _songs.length - 1) % _songs.length;
        }
        await _playSong(_current);
      } else if (event is ShuffleSongs) {
        if (_isShuffled) {
          var cur = _songs[_index];
          _songs = _allSongs;
          _index = _songs.indexOf(cur);
        } else {
          _songs = _shuffle([..._allSongs], cur: _index);
          _index = 0;
        }
        _isShuffled = !_isShuffled;
        await _playSong(_current);
      } else if (event is LoopSongs) {
        _loop = !_loop;
      } else if (event is DeleteSong) {
        var songFile = File(event.song.filePath);

        var data = {'numSongs': await db.getNumSongs(event.song.albumId) - 1};

        Future.wait([
          songFile.delete(),
          db.deleteSong(event.song.title),
          db.update(
            Tables.Albums,
            data,
            where: 'id LIKE ?',
            whereArgs: [event.song.albumId],
          ),
        ]);

        _allSongs.removeWhere((s) => s.title == event.song.title);

        var songsIndex = _songs.indexWhere((s) => s.title == event.song.title);
        if (songsIndex >= 0) {
          if (songsIndex == _index) _index++;
          _songs.removeAt(songsIndex);
        }

        syncDb.delete(SyncTables.Songs, event.song.title);
        syncDb.update(SyncTables.Albums, event.song.albumId, data);

        await db.deleteEmptyAlbums();
      }
    }

    if (_songs.length == 0) {
      yield EmptyQueue(updateData: updateData);
    } else {
      yield PlayingQueue(
        songs: _songs,
        index: _index,
        updateData: updateData,
        shuffled: _isShuffled,
        loop: _loop,
      );
    }
  }
}
