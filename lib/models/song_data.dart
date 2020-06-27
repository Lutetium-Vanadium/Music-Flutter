import "./song_metadata.dart";

class SongData extends SongMetadata {
  final String title;
  final String artist;
  final String albumId;
  final String filePath;
  final int numListens;
  final bool liked;
  final String thumbnail;
  final int length;

  SongData({
    this.filePath,
    this.title,
    this.thumbnail,
    this.albumId,
    this.artist,
    this.length,
    this.liked,
    this.numListens,
  });

  toString() {
    return "{\n\ttitle: $title,\n\tartist: $artist,\n\talbumId: $albumId,\n\tfilePath: $filePath,\n\tnumListens: $numListens,\n\tliked: $liked,\n\tthumbnail: $thumbnail,\n\tlength: $length\n}";
  }

  SongData.override(
    SongData song, {
    title,
    artist,
    albumId,
    filePath,
    numListens,
    liked,
    thumbnail,
    length,
  })  : this.title = title ?? song.title,
        this.artist = artist ?? song.artist,
        this.albumId = albumId ?? song.albumId,
        this.filePath = filePath ?? song.filePath,
        this.numListens = numListens ?? song.numListens,
        this.liked = liked ?? song.liked,
        this.thumbnail = thumbnail ?? song.thumbnail,
        this.length = length ?? song.length;

  static Map<String, dynamic> toMap(SongData song) {
    return {
      "filePath": song.filePath,
      "title": song.title,
      "thumbnail": song.thumbnail,
      "albumId": song.albumId,
      "artist": song.artist,
      "length": song.length,
      "liked": song.liked ? 1 : 0,
      "numListens": song.numListens,
    };
  }

  static List<Map<String, dynamic>> toMapArray(List<SongData> songs) {
    return List.generate(
      songs.length,
      (i) => SongData.toMap(songs[i]),
    );
  }

  static SongData fromMap(Map<String, dynamic> map) {
    return SongData(
      albumId: map["albumId"],
      artist: map["artist"],
      filePath: map["filePath"],
      length: map["length"],
      liked: map["liked"] == 0 ? false : true,
      numListens: map["numListens"],
      thumbnail: map["thumbnail"],
      title: map["title"],
    );
  }

  static List<SongData> fromMapArray(List<Map<String, dynamic>> maps) {
    return List.generate(
      maps.length,
      (i) => SongData.fromMap(maps[i]),
    );
  }
}
