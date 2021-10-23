import './song_metadata.dart';

class YoutubeSongData extends SongMetadata {
  final String artist;
  final String title;
  final int length;
  final String thumbnail;
  final String id;

  YoutubeSongData({
    this.artist,
    this.length,
    this.id,
    this.thumbnail,
    this.title,
  });

  toString() {
    return '{\n\tartist: $artist,\n\ttitle: $title,\n\tid: $id,\n\tlength: $length,\n\tthumbnail: $thumbnail\n}';
  }

  @override
  List<Object> get props => [artist, length, id, thumbnail, title];
}
