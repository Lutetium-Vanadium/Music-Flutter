part of "data_bloc.dart";

@immutable
abstract class DataEvent extends Equatable {}

class ForceUpdate extends DataEvent {
  @override
  List<Object> get props => [];
}

class DownloadSong extends DataEvent {
  final NapsterSongData song;
  DownloadSong(this.song);

  @override
  List<Object> get props => [song];
}

class DeleteSong extends DataEvent {
  final SongData song;

  DeleteSong(this.song);

  @override
  List<Object> get props => [song];
}

class AddCustomAlbum extends DataEvent {
  final String name;
  final List<String> songs;

  AddCustomAlbum({this.name, this.songs});

  @override
  List<Object> get props => [name, songs];
}

class EditCustomAlbum extends DataEvent {
  final String id;
  final List<String> songs;

  EditCustomAlbum({this.id, this.songs});

  @override
  List<Object> get props => [id, songs];
}

class AddSongToCustomAlbum extends DataEvent {
  final String id;
  final SongData song;

  AddSongToCustomAlbum({this.id, this.song});

  @override
  List<Object> get props => [id, song];
}

class DeleteCustomAlbum extends DataEvent {
  final String id;

  DeleteCustomAlbum(this.id);

  @override
  List<Object> get props => [id];
}
