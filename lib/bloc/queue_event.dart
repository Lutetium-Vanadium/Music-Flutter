part of "queue_bloc.dart";

@immutable
abstract class QueueEvent extends Equatable {}

class EnqueueSongs extends QueueEvent {
  final List<SongData> songs;
  final int index;

  EnqueueSongs({@required this.songs, this.index = 0})
      : assert(songs != null),
        assert(index != null),
        assert(index >= 0 && index < songs.length);

  @override
  List<Object> get props => [songs, index];
}

class DequeueSongs extends QueueEvent {
  @override
  List<Object> get props => [];
}

class JumpToSong extends QueueEvent {
  final int index;

  JumpToSong(this.index) : assert(index != null);

  @override
  List<Object> get props => [index];
}

class NextSong extends QueueEvent {
  @override
  List<Object> get props => [];
}

class PrevSong extends QueueEvent {
  @override
  List<Object> get props => [];
}
