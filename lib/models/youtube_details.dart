import "package:equatable/equatable.dart";

class YoutubeDetails extends Equatable {
  final String id;
  final int length;

  YoutubeDetails({this.id, this.length});

  toString() {
    return "{\n\tid: $id,\n\tlength: $length\n}";
  }

  @override
  List<Object> get props => [id, length];
}
