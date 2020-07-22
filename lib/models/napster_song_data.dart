import './song_metadata.dart';

class NapsterSongData extends SongMetadata {
  final String artist;
  final String title;
  final int length;
  final String thumbnail;
  final String albumId;

  NapsterSongData({
    this.artist,
    this.length,
    this.albumId,
    this.thumbnail,
    this.title,
  });

  toString() {
    return '{\n\tartist: $artist,\n\ttitle: $title,\n\talbumId: $albumId,\n\tlength: $length,\n\tthumbnail: $thumbnail\n}';
  }

  @override
  List<Object> get props => [artist, length, albumId, thumbnail, title];
}
