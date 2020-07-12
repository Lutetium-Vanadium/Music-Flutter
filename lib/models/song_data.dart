import "./song_metadata.dart";
import "./get_id.dart";

class SongData extends SongMetadata implements DbCollection {
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

  @override
  List<Object> get props {
    print("OVERRIDE0");
    return [
      title,
      artist,
      albumId,
      filePath,
      numListens,
      liked,
      thumbnail,
      length
    ];
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

  Map<String, dynamic> toFirebase([String youtubeId = ""]) {
    return {
      "title": this.title,
      "albumId": this.albumId,
      "artist": this.artist,
      "length": this.length,
      "liked": this.liked,
      "numListens": this.numListens,
      "youtubeId": youtubeId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "filePath": this.filePath,
      "title": this.title,
      "thumbnail": this.thumbnail,
      "albumId": this.albumId,
      "artist": this.artist,
      "length": this.length,
      "liked": this.liked ? 1 : 0,
      "numListens": this.numListens,
    };
  }

  static SongData fromFirestore(Map<String, dynamic> map,
      [int length = -1, String root = ""]) {
    return SongData(
      albumId: map["albumId"],
      artist: map["artist"],
      filePath: "$root}/songs/${map["title"]}.mp3",
      length: length,
      numListens: map["numListens"],
      thumbnail: "$root/album_images/${map["albumId"]}.jpg",
      title: map["title"],
      liked: map["liked"],
    );
  }

  static SongData fromMap(Map<String, dynamic> map) {
    return SongData(
      albumId: map["albumId"],
      artist: map["artist"],
      filePath: map["filePath"],
      length: map["length"],
      liked: map["liked"] == 1,
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

  @override
  String get getId => title;

  @override
  bool needsUpdate(other) =>
      other["title"] != title ||
      other["artist"] != artist ||
      other["liked"] != liked ||
      other["albumId"] != albumId ||
      other["numListens"] != numListens;
}

extension SongDataMapping on List<SongData> {
  List<Map<String, dynamic>> toMapArray() {
    return List.generate(
      this.length,
      (i) => this.elementAt(i).toMap(),
    );
  }
}
