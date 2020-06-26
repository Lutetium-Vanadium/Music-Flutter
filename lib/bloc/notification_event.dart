part of "notification_bloc.dart";

@immutable
abstract class NotificationEvent extends Equatable {}

class DownloadSong extends NotificationEvent {
  final NapsterSongData song;
  DownloadSong(this.song) : super();

  @override
  List<Object> get props => [song];
}
