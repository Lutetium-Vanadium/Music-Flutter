import "dart:convert";

import "package:equatable/equatable.dart";

String stringifyArr(List<dynamic> arr) {
  var strArr = jsonEncode(arr);
  return strArr.substring(1, strArr.length - 1);
}

List<String> parseArr(String arr) {
  List<dynamic> lst = jsonDecode("[$arr]");

  return lst.map((el) => el.toString()).toList();
}

class CustomAlbumData extends Equatable {
  final String id;
  final String name;
  final List<String> songs;

  CustomAlbumData({this.id, this.name, this.songs});

  toString() {
    return "{\n\tid: $id,\n\tname: $name,\n\tsongs: $songs\n}";
  }

  @override
  List<Object> get props => [id, name, songs];

  static Map<String, dynamic> toMap(CustomAlbumData album) {
    return {
      "id": album.id,
      "name": album.name,
      "songs": stringifyArr(album.songs),
    };
  }

  static List<Map<String, dynamic>> toMapArray(List<CustomAlbumData> albums) {
    return List.generate(
      albums.length,
      (i) => CustomAlbumData.toMap(albums[i]),
    );
  }

  static CustomAlbumData fromMap(Map<String, dynamic> map) {
    return CustomAlbumData(
      id: map["id"],
      name: map["name"],
      songs: parseArr(map["songs"]),
    );
  }

  static List<CustomAlbumData> fromMapArray(List<Map<String, dynamic>> maps) {
    return List.generate(
      maps.length,
      (i) => CustomAlbumData.fromMap(maps[i]),
    );
  }
}
