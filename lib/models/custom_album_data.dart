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

  Map<String, dynamic> toFirebase() {
    return {
      "id": this.id,
      "name": this.name,
      "songs": this.songs,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "name": this.name,
      "songs": stringifyArr(this.songs),
    };
  }

  static CustomAlbumData fromFirebase(Map<String, dynamic> map) {
    return CustomAlbumData(
      id: map["id"],
      name: map["name"],
      songs: map["songs"].map((e) => e.toString()).toList(),
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

extension CustomAlbumDataMapping on List<CustomAlbumData> {
  List<Map<String, dynamic>> toMapArray() {
    return List.generate(
      this.length,
      (i) => this.elementAt(i).toMap(),
    );
  }
}
