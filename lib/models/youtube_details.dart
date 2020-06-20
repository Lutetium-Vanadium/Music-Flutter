class YoutubeDetails {
  String id;
  int length;

  YoutubeDetails({this.id, this.length});

  toString() {
    return "{\n\tid: $id,\n\tlength: $length\n}";
  }
}
