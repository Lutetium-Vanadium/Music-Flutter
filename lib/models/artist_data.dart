import "package:equatable/equatable.dart";

class ArtistData extends Equatable {
  final String name;
  final List<String> images;
  final int numSongs;

  ArtistData({this.name, this.images, this.numSongs});

  toString() {
    return "{\n\tname: $name,\n\tnumSongs: $numSongs,\n\timages: $images\n}";
  }

  @override
  List<Object> get props => [name, images, numSongs];

  static ArtistData fromMapAndPreArtist(
    List<Map<String, dynamic>> images,
    PreArtist preArtist,
  ) {
    assert(images.isNotEmpty);

    return ArtistData(
      name: preArtist.name,
      numSongs: preArtist.numSongs,
      images: List.generate(
        images.length < 4 ? 1 : 4,
        (i) => images[i]["imagePath"],
      ),
    );
  }
}

class PreArtist extends Equatable {
  final String name;
  final int numSongs;

  PreArtist({this.name, this.numSongs});

  toString() {
    return "{\n\tname: $name,\n\tnumSongs: $numSongs\n}";
  }

  @override
  List<Object> get props => [name, numSongs];

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
