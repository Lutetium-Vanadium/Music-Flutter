class SongMetadata {
  final String artist;
  final String title;
  final int length;
  final String thumbnail;

  SongMetadata({
    this.artist,
    this.length,
    this.thumbnail,
    this.title,
  });

  toString() {
    return "{\n\tartist: $artist,\n\ttitle: $title,\n\tlength: $length,\n\tthumbnail: $thumbnail\n}";
  }
}
