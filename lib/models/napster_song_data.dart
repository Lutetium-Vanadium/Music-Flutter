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
