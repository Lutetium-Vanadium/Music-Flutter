class Artist {
  final String name;
  final List<String> images;
  final int numSongs;

  Artist({this.name, this.images, this.numSongs});

  toString() {
    return "{\n\tname: $name,\n\tnumSongs: $numSongs,\n\timages: $images\n}";
  }

  static Artist fromMapAndPreArtist(
    List<Map<String, dynamic>> images,
    PreArtist preArtist,
  ) {
    assert(images.isNotEmpty);

    return Artist(
      name: preArtist.name,
      numSongs: preArtist.numSongs,
      images: List.generate(
        images.length < 4 ? 1 : 4,
        (i) => images[i]["imagePath"],
      ),
    );
  }
}

class PreArtist {
  final String name;
  final int numSongs;

  PreArtist({this.name, this.numSongs});

  toString() {
    return "{\n\tname: $name,\n\tnumSongs: $numSongs\n}";
  }

  static PreArtist fromMap(Map<String, dynamic> map) {
    return PreArtist(
      name: map["name"],
      numSongs: map["numSongs"],
    );
  }

  static List<PreArtist> fromMapArray(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) => PreArtist.fromMap(maps[i]));
  }
}
