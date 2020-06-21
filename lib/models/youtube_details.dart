class YoutubeDetails {
  final String id;
  final int length;

  YoutubeDetails({this.id, this.length});

  toString() {
    return "{\n\tid: $id,\n\tlength: $length\n}";
  }
}
