part of "notification_bloc.dart";

@immutable
abstract class NotificationState extends Equatable {}

class NotificationInitial extends NotificationState {
  @override
  List<Object> get props => [];
}

class ProgressNotification extends NotificationState {
  final int bytesDownloaded;
  final int totalBytes;
  ProgressNotification({this.bytesDownloaded, this.totalBytes}) : super();

  @override
  List<Object> get props => [bytesDownloaded, totalBytes];
}

class DownloadedNotification extends NotificationState {
  @override
  List<Object> get props => [];
}

class UpdateData extends NotificationState {
  @override
  List<Object> get props => [];
}
