part of 'notification_bloc.dart';

@immutable
abstract class NotificationEvent {}

class DownloadSong extends NotificationEvent {
  final NapsterSongData song;
  DownloadSong(this.song) : super();
}
