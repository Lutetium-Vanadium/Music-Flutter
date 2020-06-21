class Album {
  final String id;
  final String imagePath;
  final String name;
  final int numSongs;
  final String artist;

  Album({this.artist, this.name, this.id, this.imagePath, this.numSongs});

  toString() {
    return "{\n\tid: $id,\n\tname: $name,\n\tartist: $artist,\n\timagePath: $imagePath,\n\tnumSongs: $numSongs\n}";
  }

  static Map<String, dynamic> toMap(Album album) {
    return {
      "id": album.id,
      "imagePath": album.imagePath,
      "name": album.name,
      "numSongs": album.numSongs,
      "artist": album.artist,
    };
  }

  static List<Map<String, dynamic>> toMapArray(List<Album> albums) {
    return List.generate(
      albums.length,
      (i) => Album.toMap(albums[i]),
    );
  }

  static Album fromMap(Map<String, dynamic> map) {
    return Album(
      id: map["id"],
      artist: map["artist"],
      name: map["name"],
      numSongs: map["numSongs"],
      imagePath: map["imagePath"],
    );
  }

  static List<Album> fromMapArray(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) => Album.fromMap(maps[i]));
  }
}
