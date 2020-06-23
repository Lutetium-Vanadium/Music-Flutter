part of "notification_bloc.dart";

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class ProgressNotification extends NotificationState {
  final int bytesDownloaded;
  final int totalBytes;
  ProgressNotification({this.bytesDownloaded, this.totalBytes}) : super();
}

class DownloadedNotification extends NotificationState {}
