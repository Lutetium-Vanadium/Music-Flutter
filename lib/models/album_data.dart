import "package:equatable/equatable.dart";

class AlbumData extends Equatable {
  final String id;
  final String imagePath;
  final String name;
  final int numSongs;
  final String artist;

  AlbumData({this.artist, this.name, this.id, this.imagePath, this.numSongs});

  toString() {
    return "{\n\tid: $id,\n\tname: $name,\n\tartist: $artist,\n\timagePath: $imagePath,\n\tnumSongs: $numSongs\n}";
  }

  @override
  List<Object> get props => [id, imagePath, name, numSongs, artist];

  static Map<String, dynamic> toMap(AlbumData album) {
    return {
      "id": album.id,
      "imagePath": album.imagePath,
      "name": album.name,
      "numSongs": album.numSongs,
      "artist": album.artist,
    };
  }

  static List<Map<String, dynamic>> toMapArray(List<AlbumData> albums) {
    return List.generate(
      albums.length,
      (i) => AlbumData.toMap(albums[i]),
    );
  }

  static AlbumData fromMap(Map<String, dynamic> map) {
    return AlbumData(
      id: map["id"],
      artist: map["artist"],
      name: map["name"],
      numSongs: map["numSongs"],
      imagePath: map["imagePath"],
    );
  }

  static List<AlbumData> fromMapArray(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) => AlbumData.fromMap(maps[i]));
  }
}
