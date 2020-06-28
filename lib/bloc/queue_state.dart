part of "queue_bloc.dart";

/// Not to happy with updateData flag on QueueState as it isnt related, but right now I dont know how to communicate between blocs
@immutable
abstract class QueueState extends Equatable {
  final bool updateData;

  QueueState({this.updateData = false});

  @override
  // TODO: implement props
  List<Object> get props => [updateData];
}

class EmptyQueue extends QueueState {
  final bool updateData;

  EmptyQueue({this.updateData = false});
}

class PlayingQueue extends QueueState {
  final List<SongData> songs;
  final int index;
  final bool updateData;
  final bool shuffled;

  PlayingQueue(
      {@required this.songs,
      this.index,
      this.updateData = false,
      this.shuffled = false})
      : assert(songs != null),
        assert(index != null),
        assert(index >= 0 && index < songs.length);

  SongData get song => songs[index];

  List<Object> get props => [songs, index, updateData, shuffled];
}
