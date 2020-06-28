import "package:equatable/equatable.dart";

class NapsterAlbumData extends Equatable {
  final String id;
  final String name;

  NapsterAlbumData({this.id, this.name});

  toString() {
    return "{\n\tid: $id,\n\tname: $name\n}";
  }

  @override
  List<Object> get props => [id, name];
}
