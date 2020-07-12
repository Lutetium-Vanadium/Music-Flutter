import "package:equatable/equatable.dart";

import "./get_id.dart";

class AlbumData extends Equatable implements DbCollection {
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

  Map<String, dynamic> toFirebase() {
    return {
      "id": this.id,
      "name": this.name,
      "numSongs": this.numSongs,
      "artist": this.artist,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "imagePath": this.imagePath,
      "name": this.name,
      "numSongs": this.numSongs,
      "artist": this.artist,
    };
  }

  static AlbumData fromFirebase(Map<String, dynamic> map, String root) {
    return AlbumData(
      id: map["id"],
      artist: map["artist"],
      name: map["name"],
      numSongs: map["numSongs"],
      imagePath: "$root/album_images/${map["id"]}.jpg",
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

  @override
  String get getId => id;

  @override
  bool needsUpdate(other) =>
      other["id"] != id ||
      other["artist"] != artist ||
      other["name"] != name ||
      other["numSongs"] != numSongs;
}

extension AlbumDataMapping on List<AlbumData> {
  List<Map<String, dynamic>> toMapArray() {
    return List.generate(
      this.length,
      (i) => this.elementAt(i).toMap(),
    );
  }
}
