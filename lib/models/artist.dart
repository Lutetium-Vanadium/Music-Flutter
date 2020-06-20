class Artist {
  String name;
  List<String> images;

  Artist({this.name, this.images});

  toString() {
    return "{\n\tname: $name,\n\timages: $images\n}";
  }
}
