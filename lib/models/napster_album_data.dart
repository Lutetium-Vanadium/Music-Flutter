class NapsterAlbumData {
  final String id;
  final String name;

  NapsterAlbumData({this.id, this.name});

  toString() {
    return "{\n\tid: $id,\n\tname: $name\n}";
  }
}
