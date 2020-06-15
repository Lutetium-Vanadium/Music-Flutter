class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}

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
}

class Album {
  String id;
  String imagePath;
  String name;
  int numSongs;
  String artist;

  Album({this.artist, this.name, this.id, this.imagePath, this.numSongs});

  toString() {
    return "{\n\tid: $id,\n\tname: $name,\n\tartist: $artist,\n\timagePath: $imagePath,\n\tnumSongs: $numSongs\n}";
  }
}

class CustomAlbum {
  String id;
  String name;
  List<String> songs;

  CustomAlbum({this.id, this.name, this.songs});

  toString() {
    return "{\n\tid: $id,\n\tname: $name,\n\tsongs: $songs\n}";
  }
}

class Artist {
  String name;
  List<String> images;

  Artist({this.name, this.images});

  toString() {
    return "{\n\tname: $name,\n\timages: $images\n}";
  }
}

class NapsterAlbumData {
  String id;
  String name;

  NapsterAlbumData({this.id, this.name});

  toString() {
    return "{\n\tid: $id,\n\tname: $name\n}";
  }
}

class NapsterSongData {
  String artist;
  String title;
  int length;
  String thumbnail;
  String albumId;

  NapsterSongData({
    this.artist,
    this.length,
    this.albumId,
    this.thumbnail,
    this.title,
  });

  toString() {
    return "{\n\tartist: $artist,\n\ttitle: $title,\n\talbumId: $albumId,\n\tlength: $length,\n\tthumbnail: $thumbnail\n}";
  }
}

class YoutubeDetails {
  String id;
  int length;

  YoutubeDetails({this.id, this.length});

  toString() {
    return "{\n\tid: $id,\n\tlength: $length\n}";
  }
}
