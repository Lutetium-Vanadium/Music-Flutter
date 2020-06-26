import "dart:async";
import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:meta/meta.dart";

import "package:Music/models/models.dart";

part "queue_event.dart";
part "queue_state.dart";

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  List<SongData> _songs = [];
  int _index = 0;

  @override
  QueueState get initialState => EmptyQueue();

  @override
  Stream<QueueState> mapEventToState(
    QueueEvent event,
  ) async* {
    if (event is EnqueueSongs) {
      _songs = event.songs;
      _index = event.index;
    } else if (event is DequeueSongs) {
      _songs = [];
      _index = 0;
    } else if (event is JumpToSong) {
      _index = event.index;
    } else if (event is NextSong) {
      _index++;
    } else if (event is PrevSong) {
      _index--;
    }

    if (_songs.length == 0) {
      yield EmptyQueue();
    } else {
      yield PlayingQueue(songs: _songs, index: _index);
    }
  }
}
