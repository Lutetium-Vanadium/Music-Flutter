part of "queue_bloc.dart";

@immutable
abstract class QueueEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class EnqueueSongs extends QueueEvent {
  final List<SongData> songs;
  final int index;
  final bool shuffle;

  EnqueueSongs({
    @required this.songs,
    this.index = 0,
    this.shuffle = false,
  })  : assert(songs != null),
        assert(index != null),
        assert(index >= 0 && index < songs.length);

  @override
  List<Object> get props => [songs, index, shuffle];
}

class DequeueSongs extends QueueEvent {}

class JumpToSong extends QueueEvent {
  final int index;

  JumpToSong(this.index) : assert(index != null);

  @override
  List<Object> get props => [index];
}

class NextSong extends QueueEvent {}

class PrevSong extends QueueEvent {}

class ShuffleSongs extends QueueEvent {}
