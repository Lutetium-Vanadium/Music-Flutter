part of "queue_bloc.dart";

@immutable
abstract class QueueState {}

class EmptyQueue extends QueueState {}

class PlayingQueue extends QueueState {
  final List<SongData> songs;
  final int index;

  PlayingQueue({@required this.songs, this.index})
      : assert(songs != null),
        assert(index != null),
        assert(index >= 0 && index < songs.length);

  SongData get song => songs[index];
}
