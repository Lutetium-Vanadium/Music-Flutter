import "dart:async";
import "dart:math";
import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:meta/meta.dart";

import "package:Music/models/models.dart";

part "queue_event.dart";
part "queue_state.dart";

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  // Data
  List<SongData> _allSongs = []; // All songs in unshuffled order
  List<SongData> _songs = []; // Current queue
  int _index = 0;

  // Flags
  bool _isShuffled = false;

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

  @override
  QueueState get initialState => EmptyQueue();

  @override
  Stream<QueueState> mapEventToState(
    QueueEvent event,
  ) async* {
    if (event is EnqueueSongs) {
      _allSongs = event.songs;
      _index = event.index;
      _songs = _shuffle([...event.songs], cur: event.index);
    } else if (event is DequeueSongs) {
      _songs = [];
      _allSongs = [];
      _index = 0;
    } else if (event is JumpToSong) {
      _index = event.index;
    } else if (event is NextSong) {
      _index++;
    } else if (event is PrevSong) {
      _index--;
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
    }

    if (_songs.length == 0) {
      yield EmptyQueue();
    } else {
      yield PlayingQueue(songs: _songs, index: _index);
    }
  }
}
