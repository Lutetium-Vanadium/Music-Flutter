import 'package:flutter/foundation.dart';

import "./helpers/db.dart" show stringifyArr, parseArr;

// Helper classes

class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}

// DB classes
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

class CustomAlbum {
  String id;
  String name;
  List<String> songs;

  CustomAlbum({this.id, this.name, this.songs});

  toString() {
    return "{\n\tid: $id,\n\tname: $name,\n\tsongs: $songs\n}";
  }

  static Map<String, dynamic> toMap(CustomAlbum album) {
    return {
      "id": album.id,
      "name": album.name,
      "songs": stringifyArr(album.songs),
    };
  }

  static List<Map<String, dynamic>> toMapArray(List<CustomAlbum> albums) {
    return List.generate(
      albums.length,
      (i) => CustomAlbum.toMap(albums[i]),
    );
  }

  static CustomAlbum fromMap(Map<String, dynamic> map) {
    return CustomAlbum(
      id: map["id"],
      name: map["name"],
      songs: parseArr(map["songs"]),
    );
  }

  static List<CustomAlbum> fromMapArray(List<Map<String, dynamic>> maps) {
    return List.generate(
      maps.length,
      (i) => CustomAlbum.fromMap(maps[i]),
    );
  }
}

// General Classes

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
