import "./napster_song_data.dart";

class Song extends NapsterSongData {
  String title;
  String artist;
  String albumId;
  String filePath;
  int numListens;
  bool liked;
  String thumbnail;
  int length;

  Song({
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

  static Map<String, dynamic> toMap(Song song) {
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

  static List<Map<String, dynamic>> toMapArray(List<Song> songs) {
    return List.generate(
      songs.length,
      (i) => Song.toMap(songs[i]),
    );
  }

  static Song fromMap(Map<String, dynamic> map) {
    return Song(
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

  static List<Song> fromMapArray(List<Map<String, dynamic>> maps) {
    return List.generate(
      maps.length,
      (i) => Song.fromMap(maps[i]),
    );
  }
}
